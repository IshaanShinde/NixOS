import { bind, Variable } from "astal"
import Wp from "gi://AstalWp"
import { Fold, Mark, Text } from "../common/Common"

export const css = `
.audio {
  padding: 0.5em 1em;
  border: var(--border) solid @fgt;
  border-radius: var(--window-radius);
  color: @fg;
}
.audio .mute {
  background: none;
  color: @accent;
}
.audio slider,
.audio highlight {
  background: @accent;
}
/* a device in a list, padded like a wifi or bluetooth row */
.audio .device {
  padding: 0.25em 0.5em;
  border-radius: var(--radius);
}
/* the device in use; hover keeps the shared hover colors */
.audio .device.active:not(:hover),
.audio .device.active:not(:hover) image {
  color: @accent;
}
`

// one kind of device: mute toggle on the icon, volume on the slider, and a folding list of every device of that kind,
// where a click makes one the default
function Kind({ endpoint, kind }: { endpoint: Wp.Endpoint; kind: "speakers" | "microphones" }) {
  const audio = Wp.get_default()!.audio
  // "speakers" and "microphones" are raw pointers to GJS, so the list is read through the getter whenever it changes
  const read = () => (kind === "speakers" ? audio.get_speakers() : audio.get_microphones()) ?? []
  const devices = Variable(read())
  audio.connect(`notify::${kind}`, () => devices.set(read()))
  const open = Variable(true)

  return (
    <box vertical vexpand spacing={4}>
      <box spacing={8}>
        <button cssClasses={["mute"]} onClicked={() => (endpoint.mute = !endpoint.mute)}>
          <image iconName={bind(endpoint, "volumeIcon")} />
        </button>
        <slider hexpand value={bind(endpoint, "volume")} onChangeValue={({ value }) => (endpoint.volume = value)} />
      </box>
      <Fold
        title={devices((list) => `${list.length} ${kind === "speakers" ? "output" : "input"}${list.length === 1 ? "" : "s"}`)}
        open={open}
        rows={devices((list) => list.map((device) => (
          <button
            cssClasses={bind(device, "isDefault").as((d) => (d ? ["device", "active"] : ["device"]))}
            onClicked={() => device.set_is_default(true)}
          >
            <box spacing={8}>
              <Mark col="c-on" icon="object-select-symbolic" shown={bind(device, "isDefault")} />
              <Text label={bind(device, "description").as((d) => d ?? device.name ?? "")} hexpand />
            </box>
          </button>
        )))}
      />
    </box>
  )
}

export default function Audio() {
  // these follow whichever device is the default, so they never need swapping out
  const wp = Wp.get_default()!
  return (
    // fills its slot (Menu.tsx), so the two lists share that space and opening or closing one changes no size
    <box cssClasses={["audio"]} vertical vexpand spacing={12}>
      <Kind endpoint={wp.defaultSpeaker} kind="speakers" />
      <Kind endpoint={wp.defaultMicrophone} kind="microphones" />
    </box>
  )
}
