{ ... }:

let
  theme = import ../theme.nix;

  ewwScss = ''
    $bg: #${theme.bg};
    $bgt: #${theme.bg}${theme.opacityHex};
    $fg: #${theme.fg};
    $fgt: #${theme.fg}${theme.opacityHex};
    $accent: #${theme.accent};
    $radius: ${toString theme.border_radius}px;
    $border: ${toString theme.border_size}px;

    * {
      all: unset;
      font-family: monospace;
      font-size: ${theme.fontsize}px;
    }

    .control-center {
      background-color: $bgt;
      background-image: url("${theme.wallpaper}");
      background-size: cover;
      border: $border solid $accent;
      border-radius: $radius;
    }

    .power {
      padding: 1em;
      background-color: $bgt;
    }

    .power-btn {
      padding: 0.75em;
      border-radius: $radius;
      color: $fg;
      font-size: 1.5em;

      &:hover {
        background-color: $fgt;
        color: $bg;
      }
    }
  '';
in
{
  programs.eww.enable = true;

  xdg.configFile."eww/eww.yuck".source = ./eww.yuck;
  xdg.configFile."eww/eww.scss".text = ewwScss;
}
