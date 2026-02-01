{ ... }:

let
  theme = import ../theme.nix;
in
{
  services.mako = {
    enable = true;
    settings = {
      "" = {
        font = "monospace ${theme.fontsize}";
        background-color = "#${theme.bg}${theme.opacityHex}";
        text-color = "#${theme.fg}${theme.opacityMax}";
        border-color = "#${theme.accent}${theme.opacityHex}";
        border-size = theme.border_size;
        border-radius = theme.border_radius;
        padding = "10";
        margin = "10";
        default-timeout = 5000;
        max-visible = 3;
      };
      "urgency=low" = {
        border-color = "#${theme.secondary}${theme.opacityHex}";
      };
      "urgency=critical" = {
        border-color = "#${theme.urgent}${theme.opacityMax}";
        default-timeout = 0;
      };
    };
  };
}
