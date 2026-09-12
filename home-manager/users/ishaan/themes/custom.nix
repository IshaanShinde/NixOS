{
  wallpaper = "~/Media/Windows XPlosion.png";

  opacity = 0.67;

  fontsize = "14";

  fontMono  = "SF Mono";
  fontSans  = "SF Pro Text";
  fontSerif = "New York";

  border_size = 2;
  border_radius = 10;

  gaps_in  =  4;
  gaps_out =  8;

  padding = "10";
  margin = "10";

  fg        = "f5e0dc"; # #f5e0dc
  bg        = "000000"; # #000000
 #bg        = "1e1e2e"; # #1e1e2e

  cursor    = "11111b"; # #11111b
  cursorH   = "f5e0dc"; # #f5e0dc
  
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

  # Other
  searchBoxMatch   = "cdd6f4"; # #cdd6f4
  searchBoxMatch2  = "313244"; # #313244 

  searchBoxNoMatch  = "11111b"; # #11111b
  searchBoxNoMatch2 = "f38ba8"; # #f38ba8 

  jumpLabels  = "11111b"; # #11111b
  jumpLabels2 = "fab387"; # #fab387

  # app-scoped css; selectors are prefixed per app by themes/gtk.nix
  thunar = {
    # the window tints at the theme opacity; inner surfaces clear so it shows
    "" = "background: alpha(@window_bg_color, 0.67);";
    ".background" = "background: transparent;";
    "headerbar, .titlebar" = "background: transparent;";
    "menubar, menubar > menuitem" = "background: transparent;";
    "toolbar, .toolbar" = "background: transparent;";
    # the path bar is a box of buttons; clear the strip, keep the buttons
    "box.horizontal, .linked" = "background: transparent;";
    ".sidebar, placessidebar, placessidebar list" = "background: transparent;";
    "scrolledwindow, treeview.view, .view" = "background: transparent;";
    "notebook, notebook stack" = "background: transparent;";
    # the paned separator is the divider; drop the sidebar's own edge so the
    # two do not stack into a double line
    ".sidebar:not(separator)" = "border-right-style: none; border-left-style: none;";
  };
}
