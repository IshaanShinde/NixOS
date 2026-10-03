import { Variable } from "astal"
import { Gtk } from "astal/gtk4"
import GLib from "gi://GLib"

const now = Variable(GLib.DateTime.new_now_local()).poll(1000, () => GLib.DateTime.new_now_local())

export const css = `
.clock {
  padding: 0.5em 1em;
  color: @fg;
}
.clock .time {
  font-size: 3em;
  font-weight: bold;
  color: @accent;
}
`

export default function Clock() {
  return (
    // fills the panel's slot; the time and date sit in its middle
    <box cssClasses={["clock"]} vertical>
      <box vertical vexpand valign={Gtk.Align.CENTER}>
        <label cssClasses={["time"]} label={now((t) => t.format("%H:%M:%S")!)} />
        <label cssClasses={["date"]} label={now((t) => t.format("%A, %d %B")!)} />
      </box>
    </box>
  )
}
