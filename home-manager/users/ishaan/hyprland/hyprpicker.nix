{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprpicker ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, P, exec, hyprpicker -a"
  ];
}