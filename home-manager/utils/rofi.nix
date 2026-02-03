{ pkgs, ... }:

let
  theme = import ../theme.nix;
  inherit (pkgs.lib) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    font = "monospace ${theme.fontsize}";

    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "";
      drun-display-format = "{name}";
    };

    theme = {
      "*" = {
        bg = mkLiteral "#${theme.bg}";
        fg = mkLiteral "#${theme.fg}";
        accent = mkLiteral "#${theme.accent}";
        urgent = mkLiteral "#${theme.urgent}";

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        spacing = 0;
      };

      window = {
        width = mkLiteral "800px";
        height = mkLiteral "500px";
        background-color = mkLiteral "@bg";
        border = mkLiteral "${toString theme.border_size}px";
        border-color = mkLiteral "@accent";
        border-radius = mkLiteral "${toString theme.border_radius}px";
        padding = mkLiteral "${theme.padding}px";
      };

      mainbox = {
        background-color = mkLiteral "transparent";
        children = map mkLiteral [ "inputbar" "listview" ];
        spacing = mkLiteral "${theme.padding}px";
      };

      # Search bar styled like a smaller window
      inputbar = {
        background-color = mkLiteral "@fg";
        text-color = mkLiteral "@bg";
        border-radius = mkLiteral "${toString theme.border_radius}px";
        padding = mkLiteral "${theme.padding}px";
        children = map mkLiteral [ "entry" ];
      };

      entry = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@bg";
        placeholder = "Search...";
        placeholder-color = mkLiteral "#${theme.sbg}";
      };

      # Results list
      listview = {
        background-color = mkLiteral "transparent";
        columns = 1;
        lines = 8;
        scrollbar = false;
        spacing = mkLiteral "4px";
        padding = mkLiteral "${theme.padding}px 0 0 0";
      };

      element = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        padding = mkLiteral "${theme.padding}px";
        border-radius = mkLiteral "${toString theme.border_radius}px";
      };

      "element selected" = {
        background-color = mkLiteral "@accent";
        text-color = mkLiteral "@bg";
      };

      "element urgent" = {
        text-color = mkLiteral "@urgent";
      };

      element-icon = {
        size = mkLiteral "24px";
        margin = mkLiteral "0 ${theme.padding}px 0 0";
        background-color = mkLiteral "transparent";
      };

      element-text = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
