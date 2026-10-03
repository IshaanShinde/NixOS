import { App, Astal, Gdk, Gtk } from "astal/gtk4"
import { execAsync, GObject } from "astal"
import cairo from "cairo"
import Graphene from "gi://Graphene"
import Gsk from "gi://Gsk"
import layout from "./layout.json"
import * as common from "./common/Common"
import * as clock from "./clock/Clock"
import * as wifi from "./wifi/Wifi"
import * as bluetooth from "./bluetooth/Bluetooth"
import * as audio from "./audio/Audio"

// one window either side of rofi, mirrored; each side's panels top to bottom, each with its share of the side's height.
// The shares are fixed, so they are sized for the most a panel ever shows: wifi's status and error lines come and go, so it gets more
const sides: Record<"left" | "right", [typeof clock, number][]> = {
  left: [[audio, 3], [wifi, 4], [bluetooth, 3]],
  right: [[clock, 1]],
}
const panels = [...sides.left, ...sides.right].map(([panel]) => panel)

// the border is only space: Frame draws the ring and the background itself.
// The padding is whole pixels: GTK lays the content out in whole pixels, so a fractional padding (1em is 18.67px here) made the
// frame overhang its window by the fraction, cutting off the outer part of the ring
const style = `
window.menu {
  background: transparent;
}
.menu .frame {
  padding: 18px;
  border: var(--border) solid transparent;
}
`

// the gap between two panels, in px like the frame's padding (Slots places panels itself, so CSS spacing doesn't reach it)
const GAP = 18

// a side's panels, each in its slot: the slots' heights come from the side's height and the shares alone, never from what the
// panels hold, so the boundaries between panels never move. A panel fills its slot and its list scrolls inside it; the slot also
// scrolls, but only content that can't fit at all would ever need it.
// Asking for no size of its own, it also keeps a wide or tall panel from resizing the window, which would push it off center
const Slots = GObject.registerClass(class Slots extends Gtk.Widget {
  declare shares: number[]

  vfunc_measure(): [number, number, number, number] {
    return [0, 0, -1, -1]
  }

  vfunc_size_allocate(width: number, height: number) {
    const total = this.shares.reduce((a, b) => a + b, 0)
    const free = height - GAP * (this.shares.length - 1)
    let y = 0
    let i = 0
    for (let child = this.get_first_child(); child; child = child.get_next_sibling(), i++) {
      // whole pixels, the last slot taking what rounding left, so the bottom edge lands exactly on the side's
      const h = i === this.shares.length - 1 ? height - y : Math.round((free * this.shares[i]) / total)
      // GTK expects a measure before every allocation; a slot's own minimum is only its scrollbar
      const [minW] = child.measure(Gtk.Orientation.HORIZONTAL, -1)
      const [minH] = child.measure(Gtk.Orientation.VERTICAL, width)
      child.allocate(Math.max(width, minW), Math.max(h, minH), -1, new Gsk.Transform().translate(new Graphene.Point({ x: 0, y })))
      y += h + GAP
    }
  }
})

export const css = [style, common.css, ...panels.map((panel) => panel.css)].join("\n")

// hyprland's window border, which CSS can't draw (a border-image ignores the rounding): a gradient ring, and the background inside it.
// Hyprland draws its border in whole screen pixels (2px at scale 1.6 is 3 pixels, not 3.2), so the ring's edges and width are
// snapped to the screen's pixels too; unsnapped, the ring smears into 2 solid pixels and a faint one and looks thinner
const Frame = GObject.registerClass(class Frame extends Gtk.Box {
  vfunc_snapshot(snapshot: Gtk.Snapshot) {
    const { size, radius: r, colors } = layout.border
    // the snapshot's origin is the content box; the ring goes around the border box, which starts up and left of it
    const [, box] = this.compute_bounds(this)
    const scale = this.get_native()?.get_surface()?.get_scale() ?? 1
    // where this widget sits in the window, whose origin is on a screen pixel
    const [, at] = this.compute_point(this.get_root()!, new Graphene.Point({ x: 0, y: 0 }))
    const snapX = (v: number) => Math.round((v + at.x) * scale) / scale - at.x
    const snapY = (v: number) => Math.round((v + at.y) * scale) / scale - at.y
    const b = Math.max(1, Math.round(size * scale)) / scale

    const x = snapX(box.get_x()), y = snapY(box.get_y())
    const w = snapX(box.get_x() + box.get_width()) - x, h = snapY(box.get_y() + box.get_height()) - y
    const cr = snapshot.append_cairo(box)

    // the background, inside the ring's inner edge so the two meet exactly
    const bg = new Gdk.RGBA()
    bg.parse(layout.background.color)
    roundedRect(cr, x + b, y + b, w - 2 * b, h - 2 * b, r)
    cr.setSourceRGBA(bg.red, bg.green, bg.blue, layout.background.alpha)
    cr.fill()

    // outer edge minus inner edge leaves the ring
    roundedRect(cr, x, y, w, h, r + b)
    roundedRect(cr, x + b, y + b, w - 2 * b, h - 2 * b, r)
    cr.setFillRule(cairo.FillRule.EVEN_ODD)

    const gradient = new cairo.LinearGradient(x, 0, x + w, 0)
    colors.forEach((hex, i) => {
      const c = new Gdk.RGBA()
      c.parse(hex)
      gradient.addColorStopRGB(i / (colors.length - 1), c.red, c.green, c.blue)
    })
    cr.setSource(gradient)
    cr.fill()
    cr.$dispose()

    super.vfunc_snapshot(snapshot)
  }
})

function roundedRect(cr: cairo.Context, x: number, y: number, w: number, h: number, r: number) {
  cr.newSubPath()
  cr.arc(x + w - r, y + r, r, -Math.PI / 2, 0)
  cr.arc(x + w - r, y + h - r, r, 0, Math.PI / 2)
  cr.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI)
  cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI)
  cr.closePath()
}


// both sides, built once at startup (App calls this as `main`)
export default function Menu() {
  Side("left", sides.left)
  Side("right", sides.right)
}

// hiding comes first and never depends on the command, so the menu always closes, even shown without rofi;
// then the menu.onEscape command, which closes rofi too
function escape() {
  App.get_windows().forEach((w) => w.hide())
  if (layout.onEscape) execAsync(["sh", "-c", layout.onEscape]).catch(print)
}

// one side's window; `menu show` / `menu hide` (app.ts) reach every window at once
function Side(side: "left" | "right", panels: typeof sides.left) {
  const slots = new Slots({ hexpand: true, vexpand: true })
  slots.shares = panels.map(([, share]) => share)
  for (const [panel] of panels) {
    new Gtk.ScrolledWindow({ hscrollbarPolicy: Gtk.PolicyType.NEVER, child: panel.default() }).set_parent(slots)
  }

  // size and place are fixed by the menu.* options (default.nix); the compositor centers the window, and an empty
  // margin twice the offset on the inner side puts the frame's center `offset` px from the screen's center.
  // The frame's size is the options' and nothing else's, since Slots asks for none
  const frame = new Frame({ cssClasses: ["frame"] })
  frame.append(slots)
  frame.set_size_request(layout.width, layout.height)
  if (side === "left") frame.marginEnd = 2 * layout.offset
  else frame.marginStart = 2 * layout.offset

  const window = (
    <window
      name={`menu-${side}`}
      namespace="menu"
      cssClasses={["menu"]}
      application={App}
      visible={false}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      // none until clicked (see below)
      keymode={Astal.Keymode.NONE}
      // Escape while the menu has the keyboard closes everything, as it does in rofi
      onKeyPressed={(_, key) => key === Gdk.KEY_Escape && escape()}
    >
      {frame}
    </window>
  ) as Astal.Window

  // only the frame takes clicks; the empty margin beside it passes them through to rofi and whatever is under it
  window.connect("map", () => {
    const region = new cairo.Region()
    region.unionRectangle({ x: frame.marginStart, y: 0, width: layout.width, height: layout.height })
    window.get_surface()?.set_input_region(region)
  })

  // Hyprland gives the keyboard to an on demand layer when it maps, and whenever the pointer so much as moves over it
  // (follow_mouse doesn't change that), which took it from rofi's search while the hidden pointer rested on the menu.
  // So the menu opens with none and takes the keyboard on a click: exclusive grabs it at once, and on the release on demand
  // keeps it (Hyprland rechecks the pointer, which is over the menu) while letting the pointer hand it back to rofi as before
  const click = new Gtk.GestureClick({ propagationPhase: Gtk.PropagationPhase.CAPTURE })
  click.connect("pressed", () => window.keymode === Astal.Keymode.NONE && (window.keymode = Astal.Keymode.EXCLUSIVE))
  // "end" also comes when a button inside claims the click, where "released" wouldn't, so exclusive never outlasts the click
  const settle = () => window.keymode === Astal.Keymode.EXCLUSIVE && (window.keymode = Astal.Keymode.ON_DEMAND)
  click.connect("end", settle)
  click.connect("cancel", settle)
  window.add_controller(click)
  // back to none, so the next open leaves the keyboard with rofi
  window.connect("unmap", () => (window.keymode = Astal.Keymode.NONE))

  // the first map pays GTK's setup (and came out at the wrong size), so it is paid here at startup instead of on the first show
  window.show()
  window.hide()
}
