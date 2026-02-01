{ ... }:

let
  theme = import ../theme.nix;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = [{
        path = "~/Media/Osot-酒保/79e5ddabae5483112e6acd103c9ef3c262037719.jpg";
      }];

      input-field = [{
        size = "200, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        placeholder_text = "";
        fade_on_empty = false;

        outline_thickness = theme.border_size;
        outer_color = theme.accent;
        inner_color = theme.surface;
        font_color = theme.fg;
      }];
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, n, exec, hyprlock"
  ];
}
