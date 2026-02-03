{ config, ... }:

let
  theme = import ../theme.nix;
  l = config.lib.formats.rasi.mkLiteral;
  border = "${toString theme.border_size}px";
  radius = "${toString theme.border_radius}px";
in
{
  programs.rofi = {
    enable = true;
    font = "monospace ${theme.fontsize}";

    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      display-drun = "";
      drun-display-format = "{name}";
      scroll-method = 1;
    };

    theme = {
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
        width = l "40em";
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
        spacing = l "0.25em";
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

      element-icon = {
        size = l "1em";
        margin = l "0 0.5em 0 0";
      };

      element-text = {
        text-color = l "inherit";
        vertical-align = l "0.25";
      };
    };
  };
}
