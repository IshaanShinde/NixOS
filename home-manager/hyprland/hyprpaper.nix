{ ... }:

{
  services.hyprpaper = {
    enable = true;
    
    settings = {
      preload = [
        # zombie fang yuan
        "~/Media/Osot-酒保/79e5ddabae5483112e6acd103c9ef3c262037719.jpg"
        # fang yuan refines fixed immortal travel
        "~/Media/Osot-酒保/792f346bf2e0325eb72350bde0336fad62037719.jpg"
        # fang yuan tai bai yun sheng
        "~/Media/Osot-酒保/6971fdc1b06f7de6b9ff335df96de56862037719.jpg"
        # qin bai sheng vs feng jiu ge
        "~/Media/Osot-酒保/88a1be1ed6e42cc5b073a91517bd109862037719.jpg" 
      ];
      
      wallpaper = [
        {
          monitor = "DP-4";
          path = "~/Media/Osot-酒保/6971fdc1b06f7de6b9ff335df96de56862037719.jpg";
          fit_mode = "cover";
        }
      ];
      
      # enables communication via hyprctl hyprpaper
      ipc = true;
      splash = false;
    };
  };
}