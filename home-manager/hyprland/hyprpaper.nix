{ ... }:

let
  theme = import ../theme.nix;
in
{
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = [
        theme.wallpaper
      ];

      wallpaper = [
        {
          monitor = "DP-4";
          path = theme.wallpaper;
          fit_mode = "cover";
        }
      ];
      
      # enables communication via hyprctl hyprpaper
      ipc = true;
      splash = false;
    };
  };
}