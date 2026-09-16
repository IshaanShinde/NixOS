{ pkgs, lib, theme, ... }:

# applies the active theme to gtk apps: adw-gtk3 supplies the stylesheet, gtk.nix redefines the colors

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    font = {
      name = theme.fontSans;
      size = builtins.fromJSON theme.fontsize;
    };

    # per-toolkit, unlike the pointer; unset leaves gtk on its default
    iconTheme = lib.mkIf (theme ? icons) theme.icons;

    # loads after the theme's own css, so these redefinitions win
    gtk3.extraCss = theme.gtkColors.css;
    gtk4.extraCss = theme.gtkColors.css;
  };

  # gtk apps pick the dark variant up from here
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
