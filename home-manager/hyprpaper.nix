# hyprpaper.nix
{ config, lib, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    
    settings = {
      preload = [
        "~/Media/wallhaven-yq5ejd.png"
        "~/Media/wallhaven-8ge85o.jpg"
      ];
      
      wallpaper = [
        "DP-4, ~/Media/wallhaven-8ge85o.jpg"
      ];
      
      # enables communication via hyprctl hyprpaper
      ipc = true; 
      # disables startup splash screen
      splash = false;
    #   splash_offset = 2.0; # irrelevant if splash = false;
    };
  };
}