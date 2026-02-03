{ config, pkgs, ... }:

let
  theme = import ../theme.nix;
  inherit (config.lib.formats.rasi) mkLiteral;
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
        bg = mkLiteral "#${theme.bg}";
        bgt = mkLiteral "#${theme.bg}${theme.opacityHex}";
        fg = mkLiteral "#${theme.fg}";
        fgt = mkLiteral "#${theme.fg}${theme.opacityHex}";
        accent = mkLiteral "#${theme.accent}";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      window = {
        width = mkLiteral "40em";
        height = mkLiteral "40em";
        background-image = mkLiteral ''url("${theme.wallpaper}", height)'';
        border = mkLiteral "${toString theme.border_size}px";
        border-color = mkLiteral "@accent";
        border-radius = mkLiteral "${toString theme.border_radius}px";
      };

      mainbox = {
        background-color = mkLiteral "@bgt";
        padding = mkLiteral "1em";
        children = map mkLiteral [ "inputbar" "listview" ];
        spacing = mkLiteral "1em";
      };

      inputbar = {
        text-color = mkLiteral "@accent";
        border = mkLiteral "${toString theme.border_size}px";
        border-color = mkLiteral "@fgt";
        border-radius = mkLiteral "${toString theme.border_radius}px";
        padding = mkLiteral "0.5em 1em";
        children = map mkLiteral [ "entry" ];
      };

      entry = {
        text-color = mkLiteral "inherit";
        placeholder = "Search...";
        placeholder-color = mkLiteral "@fgt";
      };

      listview = {
        fixed-height = false;
        spacing = mkLiteral "0.25em";
        padding = mkLiteral "0.25em 0 0 0";
      };

      element = {
        padding = mkLiteral "0.5em 1em";
        border-radius = mkLiteral "${toString theme.border_radius}px";
      };

      "element selected" = {
        background-color = mkLiteral "@fgt";
        text-color = mkLiteral "@bg";
      };

      element-icon = {
        size = mkLiteral "1em";
        margin = mkLiteral "0 0.5em 0 0";
      };

      element-text = {
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.25";
      };
    };
  };
}
