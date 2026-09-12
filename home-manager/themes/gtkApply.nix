{ pkgs, theme, ... }:

# applies the active theme to gtk apps (thunar, file dialogs, ...); adw-gtk3 supplies the stylesheet, gtk.nix redefines the colors it is built on

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

    # loads after the theme's own css, so these redefinitions win
    gtk3.extraCss = theme.gtkColors.css;
    gtk4.extraCss = theme.gtkColors.css;
  };

  # gtk apps pick the dark variant up from here
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
