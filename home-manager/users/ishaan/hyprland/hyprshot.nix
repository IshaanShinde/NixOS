{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprshot ];

  wayland.windowManager.hyprland.settings.bind = [
    ", Print, exec, hyprshot -m output"
    "SHIFT, Print, exec, hyprshot -m region"
    "ALT, Print, exec, hyprshot -m window"
  ];
}
