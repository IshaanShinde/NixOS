{ ... }:

let
  theme = import ../theme.nix;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=${theme.fontsize}";
      };
      colors = {
        background = "${theme.bg}${theme.opacityHex}";
        text = "${theme.fg}${theme.opacityMax}";
        selection = "${theme.accent}${theme.opacityHex}";
        selection-text = "${theme.bg}${theme.opacityMax}";
        border = "${theme.accent}${theme.opacityHex}";
        match = "${theme.accent}${theme.opacityMax}";
        selection-match = "${theme.bg}${theme.opacityMax}";
      };
      border = {
        width = theme.border_size;
      };
    };
  };
}
