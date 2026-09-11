{ theme, ... }:

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
        {
          monitor = "HDMI-A-2";
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