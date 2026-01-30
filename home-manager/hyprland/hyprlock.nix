{ ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];

      input-field = [{
        size = "200, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        placeholder_text = "";
        fade_on_empty = false;
        outline_thickness = 2;
        outer_color = "rgb(33ccff)";
        inner_color = "rgb(1a1a1a)";
        font_color = "rgb(ffffff)";
      }];
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, L, exec, hyprlock"
  ];
}
