import { Binding, Variable } from "astal"
import { Gtk } from "astal/gtk4"
import Pango from "gi://Pango"

// pieces more than one panel uses; Menu.tsx adds this css with the panels'.
// `.c-*` are table columns: fixed widths (in em, so they follow the font), the same in a list's header and in every row
// The look follows rofi's: flat, dim borders with the window rounding (outer radius = rounding + border, as hyprland draws it),
// and hover drawn like rofi's selected entry. GTK's own button, switch and entry styling is replaced, not layered on
export const css = `
.menu button {
  background: none;
  border: none;
  box-shadow: none;
  color: @fg;
  outline-color: @fgt;
}
.menu button:hover {
  background: @fgt;
  color: @bg;
}
.menu button:hover image {
  color: @bg;
}
.menu entry {
  padding: 0.25em 0.5em;
  background: none;
  border: var(--border) solid @fgt;
  border-radius: var(--window-radius);
  box-shadow: none;
  outline: none;
  color: @accent;
  caret-color: @accent;
}
.menu entry:focus-within {
  border-color: @fg;
}
.menu switch {
  background: alpha(@fg, 0.2);
  border: none;
  box-shadow: none;
  outline: none;
}
.menu switch:checked {
  background: @accent;
}
.menu switch slider {
  background: @fg;
  border: none;
  box-shadow: none;
}
/* a list asks for at least its scrollbar's length; GTK's default slider and padding made that 58px, more than a short list in a
   panel's share of the side has, which pushed the whole panel past its slot */
.menu scrollbar,
.menu scrollbar range,
.menu scrollbar trough {
  padding: 0;
  margin: 0;
  min-height: 0;
}
.menu scrollbar slider {
  background: @fgt;
  min-height: 0.5em;
  margin: 0;
}
.menu .fold-title {
  padding: 0.25em 0;
}
.menu .fold-title:hover {
  background: none;
  color: @accent;
}
.menu .fold-title:hover image {
  color: @accent;
}
.menu .fold scrolledwindow {
  margin-top: 0.25em;
}
/* same padding as a row's button, and the same font, since the columns are sized in em */
.menu .head {
  padding: 0 0.5em;
}
.menu .row {
  border-radius: var(--radius);
}
.menu .row.open {
  background: alpha(@fg, 0.08);
}
.menu .row > button {
  padding: 0.25em 0.5em;
  border-radius: var(--radius);
}
.menu .row .actions {
  padding: 0 0.5em 0.5em 0.5em;
}
.menu .actions button {
  padding: 0.1em 0.5em;
  border: var(--border) solid @fgt;
  border-radius: var(--window-radius);
}
.menu .c-signal { min-width: 2.25em; }
.menu .c-icon { min-width: 1.5em; }
.menu .c-sec { min-width: 2.75em; }
.menu .c-batt { min-width: 3em; }
.menu .c-on { min-width: 1.25em; }
.menu .dim {
  color: @fgt;
}
.menu .error {
  color: @urgent;
}
.menu levelbar block {
  min-width: 3px;
  min-height: 0.8em;
  border-radius: 1px;
}
.menu levelbar block.empty {
  background: alpha(@fg, 0.2);
}
.menu levelbar block.filled {
  background: @accent;
}
.menu levelbar trough {
  background: none;
  border: none;
  padding: 0;
}
`

// a label that shortens with "…" instead of widening the window (which would push it off center)
export function Text({ label, dim = false, hexpand = false }: { label: string | Binding<string>; dim?: boolean; hexpand?: boolean }) {
  return <label label={label} xalign={0} hexpand={hexpand} ellipsize={Pango.EllipsizeMode.END} maxWidthChars={1} cssClasses={dim ? ["dim"] : []} />
}

// one fixed width table cell (`col` is one of the .c-* classes above); text in it shortens rather than pushing its neighbours
export function Cell({ col, label, dim = false, xalign = 0 }: { col: string; label: string | Binding<string>; dim?: boolean; xalign?: number }) {
  return <label cssClasses={dim ? [col, "dim"] : [col]} label={label} xalign={xalign} ellipsize={Pango.EllipsizeMode.END} maxWidthChars={1} />
}

// an icon in a fixed cell; hiding it keeps its space, so the cells after it stay put
export function Mark({ col, icon, shown }: { col: string; icon: string | Binding<string>; shown: boolean | Binding<boolean> }) {
  const opacity = shown instanceof Binding ? shown.as((s) => (s ? 1 : 0)) : shown ? 1 : 0
  return <image cssClasses={[col]} iconName={icon} opacity={opacity} />
}

// range indicator: 0 to 4 bars, in the signal column
export function Bars({ level }: { level: Binding<number> }) {
  return (
    <box cssClasses={["c-signal"]}>
      <levelbar
        valign={Gtk.Align.CENTER}
        mode={Gtk.LevelBarMode.DISCRETE}
        minValue={0}
        maxValue={4}
        value={level}
        // the default offsets color the bar low/high/full; one accent color is enough
        setup={(self) => ["low", "high", "full"].forEach((name) => self.remove_offset_value(name))}
      />
    </box>
  )
}

// a button in a row's actions; the buttons share the row's width instead of asking for their labels' width
export function Action({ label, visible, onClicked }: { label: string; visible: boolean | Binding<boolean>; onClicked: () => void }) {
  return (
    <button hexpand visible={visible} onClicked={onClicked}>
      <label label={label} ellipsize={Pango.EllipsizeMode.END} maxWidthChars={1} />
    </button>
  )
}

// a list that folds away under its title; the panel keeps its size either way, and a long list scrolls inside it.
// `head` is the column captions, shown above the rows, if the list has columns
export function Fold({ title, open, head, rows, extra }: { title: Binding<string>; open: Variable<boolean>; head?: Gtk.Widget; rows: Binding<Gtk.Widget[]>; extra?: Gtk.Widget }) {
  const scroll = new Gtk.ScrolledWindow({ vexpand: true, hscrollbarPolicy: Gtk.PolicyType.NEVER })
  scroll.set_child(<box vertical spacing={2}>{rows}</box>)

  return (
    <box cssClasses={["fold"]} vertical vexpand>
      <box spacing={8}>
        <button cssClasses={["fold-title"]} hexpand onClicked={() => open.set(!open.get())}>
          <box spacing={8}>
            <image iconName={open((o) => (o ? "pan-down-symbolic" : "pan-end-symbolic"))} />
            <Text label={title} hexpand />
          </box>
        </button>
        {extra}
      </box>
      <revealer vexpand revealChild={open()} transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}>
        <box vertical>
          {head && <box cssClasses={["head", "dim"]}>{head}</box>}
          {scroll}
        </box>
      </revealer>
    </box>
  )
}

// one list entry: a summary line that opens to show its actions; `open` holds the key of the one open entry
export function Row({ id, open, summary, actions }: { id: string; open: Variable<string>; summary: Gtk.Widget; actions: Gtk.Widget }) {
  return (
    <box cssClasses={open((o) => (o === id ? ["row", "open"] : ["row"]))} vertical>
      <button onClicked={() => open.set(open.get() === id ? "" : id)}>{summary}</button>
      <revealer revealChild={open((o) => o === id)}>{actions}</revealer>
    </box>
  )
}

// rows are reused by key, so a list refresh doesn't throw away an open row's half typed password
export function keyed<T>(make: (item: T) => Gtk.Widget, key: (item: T) => string) {
  let made = new Map<string, Gtk.Widget>()
  return (items: T[]) => {
    const kept = new Map(items.map((item) => [key(item), made.get(key(item)) ?? make(item)]))
    made = kept
    return [...kept.values()]
  }
}

