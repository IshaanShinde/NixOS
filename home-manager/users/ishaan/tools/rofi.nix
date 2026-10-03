{ config, lib, pkgs, theme, ... }:

let
  l = config.lib.formats.rasi.mkLiteral;
  border = "${toString theme.border_size}px";
  radius = "${toString theme.border_radius}px";

  # rofi has no grid switch; the layout falls out of the listview/element blocks below
  gridMode = false;

  # rofi and the menu panel share SUPER+R: rofi centered, one menu window a gap away on either side
  # logical px, because rofi's em (line height) and GTK's em (font size) differ
  pair = {
    rofi = if gridMode then 1266 else 600;
    menu = 380;
    gap = theme.gaps_out;
    height = 920;
  };
  px = n: l "${toString n}px";

  # only what differs; the rest is shared below, merged by recursiveUpdate
  layout = if gridMode then {
    window.width = px pair.rofi;
    listview = { columns = 5; lines = 4; fixed-columns = true; fixed-height = true; };
    # spacing = gap between icon and label
    element = { orientation = l "vertical"; padding = l "0.75em 0.25em"; spacing = l "0.5em"; };
    element-icon = { size = l "2.5em"; horizontal-align = l "0.5"; };
    element-text = { horizontal-align = l "0.5"; vertical-align = l "0.5"; };
  } else {
    window.width = px pair.rofi;
    listview.spacing = l "0.25em";
    element.padding = l "0.5em 1em";
    element-icon = { size = l "1em"; margin = l "0 0.5em 0 0"; };
    element-text = { horizontal-align = l "0.5"; vertical-align = l "0.25"; };
  };
in
{
  # each menu window's center sits off the screen's by half of rofi, the gap, and half of itself
  menu = {
    width = pair.menu;
    height = pair.height;
    offset = (pair.rofi + pair.menu) / 2 + pair.gap;
    # Escape over the menu closes rofi too; the bind's `menu hide` then follows, as it does after Escape in rofi
    onEscape = "${pkgs.procps}/bin/pkill -x rofi";
  };

  programs.rofi = {
    enable = true;
    # patched so `border-image` takes a gradient, like hyprland's col.active_border, and so it takes the keyboard
    # on demand instead of exclusively, which would keep every click away from the menu beside it
    package = pkgs.rofi.override {
      rofi-unwrapped = pkgs.rofi-unwrapped.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./rofi-border-image.patch ./rofi-keyboard-on-demand.patch ];
      });
    };
    font = "${theme.fontMono} ${theme.fontsize}";

    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      display-drun = "";
      drun-display-format = "{name}";
      scroll-method = 1;
      # only Escape closes it, so clicking the menu panel beside it doesn't
      click-to-exit = false;
    }
    # rofi takes the icon theme name itself; unset leaves it on its default
    // (if theme ? icons then { icon-theme = theme.icons.name; } else { });

    theme = lib.recursiveUpdate {
      "*" = {
        bg = l "#${theme.bg}";
        bgt = l "#${theme.bg}${theme.opacityHex}";
        fg = l "#${theme.fg}";
        fgt = l "#${theme.fg}${theme.opacityHex}";
        accent = l "#${theme.accent}";
        background-color = l "transparent";
        text-color = l "@fg";
      };

      window = {
        height = px pair.height;
        # always dead center: on wayland rofi ignores x-offset unless anchored to an edge
        location = l "center";
        background-color = l "@bgt";
        border = l border;
        border-color = l "@accent";
        # hyprland's 180deg runs from its second color on the left to its first on the right
        border-image = l "linear-gradient(to right, #${theme.accent2 or theme.accent}, #${theme.accent})";
        # rofi rounds the outer edge, hyprland the inner one with its border outside; this matches the window corners
        border-radius = l "${toString (theme.border_radius + theme.border_size)}px";
      };

      mainbox = {
        # background-color = l "@bgt";
        padding = l "1em";
        children = map l [ "inputbar" "listview" ];
        spacing = l "1em";
      };

      inputbar = {
        text-color = l "@accent";
        border = l border;
        border-color = l "@fgt";
        # bordered, so rounded like a window (and like the menu's panels): rounding plus border
        border-radius = l "${toString (theme.border_radius + theme.border_size)}px";
        padding = l "0.5em 1em";
        children = map l [ "entry" ];
      };

      entry = {
        text-color = l "inherit";
        placeholder = ">w<";
        placeholder-color = l "@fgt";
      };

      listview = {
        fixed-height = false;
        spacing = l "0.5em";
        padding = l "0.25em 0 0 0";
      };

      element = {
        padding = l "0.5em 1em";
        border-radius = l radius;
      };

      "element selected" = {
        background-color = l "@fgt";
        text-color = l "@bg";
      };

      element-text.text-color = l "inherit";
    } layout;
  };
}
