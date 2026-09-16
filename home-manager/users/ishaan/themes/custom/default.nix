{ pkgs, wallpapers }:

{
  wallpaper = wallpapers.windows-xplosion;

  opacity = 0.67;

  fontsize = "14";

  fontMono  = "SF Mono";
  fontSans  = "SF Pro Text";
  fontSerif = "New York";

  # `name` is the directory under share/icons, `package` is what puts it there;
  # both together so the two can't drift apart. `ls $(nix build --no-link
  # --print-out-paths nixpkgs#<pkg>)/share/icons` lists the names a package ships
  icons = {
    name = "ketsa";
    package = pkgs.ketsa-icon-theme;
  };

  cursor_theme = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  border_size = 2;
  border_radius = 4;

  gaps_in  =  2;
  gaps_out =  8;

  padding = "10";
  margin = "10";

  fg        = "f5e0dc"; # #f5e0dc
  bg        = "000000"; # #000000
 #bg        = "1e1e2e"; # #1e1e2e
  
  sfg       = "cdd6f4"; # #cdd6f4
  sbg       = "414356"; # #414356

  divider   = "000000"; # #000000

  urls      = "89b4fa"; # #89b4fa
  accent    = "ff0000"; # #f5e0dc #ff0000
  accent2   = "7c3ae0"; # #7c3ae0
  urgent    = "bd1f1f"; # #bd1f1f # nothing was red enough so I added this

  ansi = {
    b00 = "45475a"; # #45475a
    b01 = "f38ba8"; # #f38ba8
    b02 = "a6e3a1"; # #a6e3a1
    b03 = "f9e2af"; # #f9e2af
    b04 = "89b4fa"; # #89b4fa
    b05 = "f5c2e7"; # #f5c2e7
    b06 = "94e2d5"; # #94e2d5
    b07 = "bac2de"; # #bac2de
    b08 = "585b70"; # #585b70
    b09 = "f38ba8"; # #f38ba8
    b10 = "a6e3a1"; # #a6e3a1
    b11 = "f9e2af"; # #f9e2af
    b12 = "89b4fa"; # #89b4fa
    b13 = "f5c2e7"; # #f5c2e7
    b14 = "94e2d5"; # #94e2d5
    b15 = "a6adc8"; # #a6adc8

    b16 = "fab387"; # #fab387
    b17 = "f5e0dc"; # #f5e0dc
  };

  # per-app css, scoped to `.<app>` by themes/gtk.nix
  # each is either an attrset of selector -> declarations (scoped and emitted
  # for both states automatically) or a string of verbatim css (own the
  # scoping and :backdrop yourself); inline it here when it is a line or two,
  # or keep it in ./apps when it grows
  apps = {
    thunar = import ./apps/thunar.nix;
  };
}
