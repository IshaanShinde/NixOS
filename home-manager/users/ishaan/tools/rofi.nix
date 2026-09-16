{ config, lib, theme, ... }:

let
  l = config.lib.formats.rasi.mkLiteral;
  border = "${toString theme.border_size}px";
  radius = "${toString theme.border_radius}px";

  # rofi has no grid switch; the layout falls out of the listview/element blocks below
  gridMode = false;

  # only what differs; the rest is shared below, merged by recursiveUpdate
  layout = if gridMode then {
    window.width = l "55em";
    listview = { columns = 5; lines = 4; fixed-columns = true; fixed-height = true; };
    # spacing = gap between icon and label
    element = { orientation = l "vertical"; padding = l "0.75em 0.25em"; spacing = l "0.5em"; };
    element-icon = { size = l "2.5em"; horizontal-align = l "0.5"; };
    element-text = { horizontal-align = l "0.5"; vertical-align = l "0.5"; };
  } else {
    window.width = l "40em";
    listview.spacing = l "0.25em";
    element.padding = l "0.5em 1em";
    element-icon = { size = l "1em"; margin = l "0 0.5em 0 0"; };
    element-text.vertical-align = l "0.25";
  };
in
{
  programs.rofi = {
    enable = true;
    font = "${theme.fontMono} ${theme.fontsize}";

    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      display-drun = "";
      drun-display-format = "{name}";
      scroll-method = 1;
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
        height = l "40em";
        location = l "center";
        x-offset = l "-6em";
        background-color = l "@bgt";
        border = l border;
        border-color = l "@accent";
        border-radius = l radius;
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
        border-radius = l radius;
        padding = l "0.5em 1em";
        children = map l [ "entry" ];
      };

      entry = {
        text-color = l "inherit";
        placeholder = "Search...";
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
