import { bind, Binding, Variable } from "astal"
import { Gtk } from "astal/gtk4"
import Gio from "gi://Gio"
import Network from "gi://AstalNetwork"
import NM from "gi://NM"
import { Action, Bars, Cell, Fold, keyed, Mark, Row, Text } from "../common/Common"

export const css = `
.wifi {
  padding: 0.5em 1em;
  border: var(--border) solid @fgt;
  border-radius: var(--window-radius);
  color: @fg;
}
.wifi image {
  color: @accent;
}
.wifi .c-key {
  min-width: 5em;
}
.wifi .rescan {
  background: none;
  padding: 0 0.25em;
}
`

// these NetworkManager calls take a callback; promisified, they can be awaited instead
Gio._promisify(Network.AccessPoint.prototype, "activate", "activate_finish")
Gio._promisify(Network.Wifi.prototype, "deactivate_connection", "deactivate_connection_finish")
Gio._promisify(NM.Client.prototype, "add_and_activate_connection_async", "add_and_activate_connection_finish")
Gio._promisify(NM.RemoteConnection.prototype, "get_secrets_async", "get_secrets_finish")
Gio._promisify(NM.RemoteConnection.prototype, "commit_changes_async", "commit_changes_finish")
Gio._promisify(NM.RemoteConnection.prototype, "delete_async", "delete_finish")

const SECURITY = "802-11-wireless-security"

function band(mhz: number) {
  return mhz >= 5925 ? "6 GHz" : mhz >= 4900 ? "5 GHz" : "2.4 GHz"
}

// signal strength (0 to 100) as 0 to 4 bars
const bars = (strength: number) => Math.ceil(strength / 25)

// NM's 802.11 security flag bits (NM.80211ApSecurityFlags), and the privacy bit that alone means WEP
const PSK = 0x100, EAP = 0x200, SAE = 0x400, PRIVACY = 0x1

// what the security column shows
function security(ap: Network.AccessPoint) {
  const flags = ap.rsnFlags | ap.wpaFlags
  if (flags & EAP) return "eap"
  if (ap.rsnFlags & SAE) return "wpa3"
  if (ap.rsnFlags & PSK) return "wpa2"
  if (ap.wpaFlags) return "wpa"
  return ap.flags & PRIVACY ? "wep" : "open"
}

export default function Wifi() {
  const network = Network.get_default()
  // null on a machine with no wifi device
  const wifi = network.wifi
  if (!wifi) return <label cssClasses={["wifi"]} label="no wifi device" />

  // what's in progress, and what went wrong last (kept until the next action)
  const busy = Variable("")
  const error = Variable("")
  const run = (label: string, action: () => Promise<unknown>) => {
    busy.set(label)
    error.set("")
    action().then(() => busy.set(""), (e) => (busy.set(""), error.set(String(e.message ?? e))))
  }
  // a failed activation only shows up here, after `activate` itself has returned
  wifi.connect("state-changed", (_, state) => {
    if (state === Network.DeviceState.FAILED) error.set("couldn't connect; wrong password?")
  })

  // the connected network's details, one labelled line each, so every value has its own place
  const connectedTo = bind(wifi, "ssid")
  const details: [string, Binding<string>][] = [
    ["signal", Variable.derive([connectedTo, bind(wifi, "strength")], (ssid, s) => (ssid ? `${s}%` : "none"))()],
    ["band", Variable.derive([connectedTo, bind(wifi, "frequency")], (ssid, f) => (ssid ? band(f) : "none"))()],
    ["internet", bind(network, "connectivity").as((c) =>
      c === Network.Connectivity.FULL ? "yes" : c === Network.Connectivity.PORTAL ? "login needed" : c === Network.Connectivity.LIMITED ? "limited" : "no")],
  ]

  // one entry per name (the strongest of its access points), hidden ones left out, the connected one first
  const networks = Variable.derive([bind(wifi, "accessPoints"), bind(wifi, "activeAccessPoint")], (aps, active) => {
    const best = new Map<string, Network.AccessPoint>()
    for (const ap of aps) {
      if (!ap.ssid) continue
      const seen = best.get(ap.ssid)
      if (!seen || ap.strength > seen.strength) best.set(ap.ssid, ap)
    }
    const first = (ap: Network.AccessPoint) => (ap.ssid === active?.ssid ? 1 : 0)
    return [...best.values()].sort((a, b) => first(b) - first(a) || b.strength - a.strength)
  })

  const listOpen = Variable(true)
  const showAddress = Variable(false)
  const rowOpen = Variable("")

  // one network: range, name, band, lock and connected marks; open, it shows the password and what can be done
  function Entry(ap: Network.AccessPoint) {
    const connected = bind(wifi, "activeAccessPoint").as((a) => a?.ssid === ap.ssid)
    const saved = Variable(ap.get_connections().length > 0)
    // a folded row still counts its width, so the entry asks for none and takes what the row has
    const password = new Gtk.PasswordEntry({ showPeekIcon: true, hexpand: true, widthChars: 1, placeholderText: "password" })
    password.visible = ap.requiresPassword

    // opening the row fills in the saved password, hidden until the eye is clicked
    rowOpen.subscribe((id) => {
      if (id !== ap.bssid) return
      const [conn] = ap.get_connections()
      saved.set(!!conn)
      if (!conn || !ap.requiresPassword) return
      conn.get_secrets_async(SECURITY, null)
        .then((secrets: any) => (password.text = secrets.recursiveUnpack()[SECURITY]?.psk ?? ""))
        .catch(() => (password.placeholderText = "saved (not readable)"))
    })

    const connect = () => {
      if (ap.requiresPassword && !password.text) return error.set("needs a password")
      // a saved or secured network goes through astal, which saves a changed password first; a new open one needs no settings
      if (!ap.requiresPassword && ap.get_connections().length === 0)
        run(`connecting to ${ap.ssid}`, () => network.client.add_and_activate_connection_async(null, wifi.device, ap.get_path(), null))
      else run(`connecting to ${ap.ssid}`, () => ap.activate(ap.requiresPassword ? password.text : null))
    }
    password.connect("activate", connect)

    // changes the saved password without reconnecting
    const save = () => run("saving password", async () => {
      const [conn] = ap.get_connections()
      conn.get_setting_wireless_security().psk = password.text
      await conn.commit_changes_async(true, null)
    })

    const forget = () => run(`forgetting ${ap.ssid}`, async () => {
      for (const conn of ap.get_connections()) await conn.delete_async(null)
      saved.set(false)
      password.text = ""
    })

    return (
      <Row
        id={ap.bssid}
        open={rowOpen}
        summary={
          <box spacing={8}>
            <Bars level={bind(ap, "strength").as(bars)} />
            <Text label={ap.ssid!} hexpand />
            <Cell col="c-sec" label={security(ap)} dim />
            <Mark col="c-on" icon="object-select-symbolic" shown={connected} />
          </box>
        }
        actions={
          <box cssClasses={["actions"]} vertical spacing={6}>
            <Text label={bind(ap, "strength").as((s) => `${s}%  ·  ${band(ap.frequency)}  ·  ${ap.bssid}`)} dim />
            {password}
            <box spacing={6} homogeneous>
              <Action visible={connected.as((c) => !c)} onClicked={connect} label="connect" />
              <Action visible={connected} onClicked={() => run("disconnecting", () => wifi.deactivate_connection())} label="disconnect" />
              <Action visible={saved((s) => s && ap.requiresPassword)} onClicked={save} label="save" />
              <Action visible={saved()} onClicked={forget} label="forget" />
            </box>
          </box>
        }
      />
    )
  }

  const rescan = (
    <button cssClasses={["rescan"]} sensitive={bind(wifi, "scanning").as((s) => !s)} onClicked={() => wifi.scan()}>
      <image iconName="view-refresh-symbolic" />
    </button>
  ) as Gtk.Widget

  return (
    <box
      cssClasses={["wifi"]}
      vertical
      spacing={8}
      // a fresh list each time the menu opens
      setup={(self) => self.connect("map", () => (showAddress.set(false), wifi.enabled && wifi.scan()))}
    >
      <box spacing={8}>
        <image iconName={bind(wifi, "iconName")} />
        <Text label={bind(wifi, "ssid").as((ssid) => ssid ?? "disconnected")} hexpand />
        <switch valign={Gtk.Align.CENTER} active={bind(wifi, "enabled")} onNotifyActive={({ active }) => (wifi.enabled = active)} />
      </box>
      {details.map(([key, value]) => (
        <box spacing={8}>
          <Cell col="c-key" label={key} dim />
          <Text label={value} hexpand />
        </box>
      ))}
      {/* folded like the network list, so the address isn't on screen every time the menu opens; it folds again on the next open */}
      <box vertical>
        <button cssClasses={["fold-title"]} onClicked={() => showAddress.set(!showAddress.get())}>
          <box spacing={8}>
            <image iconName={showAddress((s) => (s ? "pan-down-symbolic" : "pan-end-symbolic"))} />
            <Text label="address" hexpand />
          </box>
        </button>
        <revealer revealChild={showAddress()} transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}>
          <Text label={bind(wifi.device, "ip4-config").as((ip4: NM.IPConfig | null) => ip4?.get_addresses()[0]?.get_address() ?? "none")} />
        </revealer>
      </box>
      <label cssClasses={["dim"]} xalign={0} wrap maxWidthChars={1} visible={busy((s) => s !== "")} label={busy()} />
      <label cssClasses={["error"]} xalign={0} wrap maxWidthChars={1} visible={error((s) => s !== "")} label={error()} />
      <Fold
        title={Variable.derive([networks, bind(wifi, "scanning")], (list, scanning) => `${list.length} network${list.length === 1 ? "" : "s"}${scanning ? ", scanning" : ""}`)()}
        open={listOpen}
        head={
          <box spacing={8} hexpand>
            <Cell col="c-signal" label="sig" />
            <Text label="network" hexpand />
            <Cell col="c-sec" label="sec" />
            <Cell col="c-on" label="" />
          </box>
        }
        rows={networks(keyed(Entry, (ap) => ap.bssid))}
        extra={rescan}
      />
    </box>
  )
}
