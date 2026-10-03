import { bind, Variable } from "astal"
import { Gtk } from "astal/gtk4"
import Gio from "gi://Gio"
import Bluetooth from "gi://AstalBluetooth"
import { Action, Bars, Cell, Fold, keyed, Mark, Row, Text } from "../common/Common"

export const css = `
.bluetooth {
  padding: 0.5em 1em;
  border: var(--border) solid @fgt;
  border-radius: var(--window-radius);
  color: @fg;
}
.bluetooth image {
  color: @accent;
}
`

Gio._promisify(Bluetooth.Device.prototype, "connect_device", "connect_device_finish")
Gio._promisify(Bluetooth.Device.prototype, "disconnect_device", "disconnect_device_finish")

// astal's `pair()` waits on bluez without letting the menu redraw, for as long as pairing takes; this asks bluez directly instead
function pair(device: Bluetooth.Device, adapter: string) {
  const path = `${adapter}/dev_${device.address.replaceAll(":", "_")}`
  return new Promise<void>((resolve, reject) =>
    Gio.DBus.system.call("org.bluez", path, "org.bluez.Device1", "Pair", null, null, Gio.DBusCallFlags.NONE, 60_000, null, (bus, res) => {
      try { bus!.call_finish(res); resolve() } catch (e) { reject(e) }
    }),
  )
}

// received signal strength (dBm, 0 when unknown) as 0 to 4 bars
const bars = (rssi: number) => (rssi === 0 ? 0 : rssi >= -60 ? 4 : rssi >= -70 ? 3 : rssi >= -80 ? 2 : 1)

// bluez can start after the menu, or restart, so the panel is rebuilt whenever the adapter comes or goes
export default function BluetoothPanel() {
  const bt = Bluetooth.get_default()
  return (
    <box cssClasses={["bluetooth-slot"]} vertical>
      {bind(bt, "adapter").as((adapter) => (adapter ? Panel(bt, adapter) : <label cssClasses={["bluetooth"]} vexpand label="no bluetooth adapter" />))}
    </box>
  )
}

function Panel(bt: Bluetooth.Bluetooth, adapter: Bluetooth.Adapter) {
  const busy = Variable("")
  const error = Variable("")
  const run = (label: string, action: () => Promise<unknown>) => {
    busy.set(label)
    error.set("")
    action().then(() => busy.set(""), (e) => (busy.set(""), error.set(String(e.message ?? e))))
  }

  // `devices` only changes when one appears or goes; `isConnected` is what moves on a connect
  const connected = Variable.derive([bind(bt, "devices"), bind(bt, "isConnected")], (devices) =>
    devices.filter((d) => d.connected).map((d) => d.alias).join(", ") || "nothing connected",
  )

  // named devices only (scanning also finds a lot of bare addresses): connected, then paired, then nearest
  const devices = bind(bt, "devices").as((all) => {
    const rank = (d: Bluetooth.Device) => (d.connected ? 2 : d.paired ? 1 : 0)
    return all.filter((d) => d.name).sort((a, b) => rank(b) - rank(a) || b.rssi - a.rssi)
  })

  const listOpen = Variable(true)
  const rowOpen = Variable("")

  // looking for new devices runs while the list is open in a shown menu, and stops after a minute
  let stopAt = 0
  const discover = (on: boolean) => {
    try {
      if (on && adapter.powered && !adapter.discovering) {
        adapter.start_discovery()
        const at = (stopAt = Date.now())
        setTimeout(() => stopAt === at && discover(false), 60_000)
      }
      if (!on && adapter.discovering) adapter.stop_discovery()
    } catch (e) {
      error.set(String(e))
    }
  }

  // one device: range, name, battery and connected marks; open, what can be done with it
  function Entry(device: Bluetooth.Device) {
    const state = Variable.derive([bind(device, "connected"), bind(device, "paired"), bind(device, "connecting")], (c, p, ing) =>
      ing ? "connecting" : c ? "connected" : p ? "paired" : "",
    )
    return (
      <Row
        id={device.address}
        open={rowOpen}
        summary={
          <box spacing={8}>
            <Bars level={bind(device, "rssi").as(bars)} />
            <Mark col="c-icon" icon={device.icon ? `${device.icon}-symbolic` : "bluetooth-symbolic"} shown />
            <Text label={bind(device, "alias")} hexpand />
            <Cell col="c-batt" label={bind(device, "batteryPercentage").as((b) => (b < 0 ? "" : `${Math.round(b * 100)}%`))} dim />
            <Mark col="c-on" icon="object-select-symbolic" shown={bind(device, "connected")} />
          </box>
        }
        actions={
          <box cssClasses={["actions"]} vertical spacing={6}>
            <Text label={Variable.derive([state, bind(device, "rssi")], (s, rssi) => [s, rssi ? `${rssi} dBm` : "", device.address].filter(Boolean).join("  ·  "))()} dim />
            <box spacing={6} homogeneous>
              <Action visible={bind(device, "paired").as((p) => !p)} label="pair"
                onClicked={() => run(`pairing with ${device.alias}`, async () => {
                  await pair(device, String(device.adapter))
                  device.trusted = true // so it can reconnect by itself later
                  await device.connect_device()
                })} />
              <Action visible={Variable.derive([bind(device, "paired"), bind(device, "connected")], (p, c) => p && !c)()} label="connect"
                onClicked={() => run(`connecting to ${device.alias}`, () => device.connect_device())} />
              <Action visible={bind(device, "connected")} label="disconnect"
                onClicked={() => run(`disconnecting ${device.alias}`, () => device.disconnect_device())} />
              <Action visible={bind(device, "paired")} label="forget"
                onClicked={() => run(`forgetting ${device.alias}`, async () => adapter.remove_device(device))} />
            </box>
          </box>
        }
      />
    )
  }

  return (
    <box
      cssClasses={["bluetooth"]}
      vexpand
      vertical
      spacing={8}
      setup={(self) => {
        self.connect("map", () => listOpen.get() && discover(true))
        self.connect("unmap", () => discover(false))
        listOpen.subscribe((open) => discover(open && self.get_mapped()))
      }}
    >
      <box spacing={8}>
        <image iconName="bluetooth-symbolic" />
        <Text label={connected()} hexpand />
        <switch valign={Gtk.Align.CENTER} active={bind(bt, "isPowered")} onNotifyActive={({ active }) => (adapter.powered = active)} />
      </box>
      <label cssClasses={["dim"]} xalign={0} wrap maxWidthChars={1} visible={busy((s) => s !== "")} label={busy()} />
      <label cssClasses={["error"]} xalign={0} wrap maxWidthChars={1} visible={error((s) => s !== "")} label={error()} />
      <Fold
        title={Variable.derive([devices, bind(adapter, "discovering")], (list, scanning) => `${list.length} device${list.length === 1 ? "" : "s"}${scanning ? ", scanning" : ""}`)()}
        open={listOpen}
        head={
          <box spacing={8} hexpand>
            <Cell col="c-signal" label="sig" />
            <Cell col="c-icon" label="" />
            <Text label="device" hexpand />
            <Cell col="c-batt" label="batt" />
            <Cell col="c-on" label="" />
          </box>
        }
        rows={devices.as(keyed(Entry, (d) => d.address))}
      />
    </box>
  )
}
