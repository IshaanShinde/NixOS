{ utils }:

# resolves a theme name against ./presets plus the user's own dir; returns a module to import, not an attrset
{ name, userThemes ? null }:

# a module, so `pkgs` arrives from the module system rather than the flake; a
# theme file is a function taking `{ pkgs, wallpapers }`, which is how it names
# packages and wallpapers instead of just naming strings
{ pkgs, ... }:

let
  shared = utils.importNixFilesIn ./presets;

  personal =
    if userThemes != null && builtins.pathExists userThemes
    then utils.importNixFilesIn userThemes
    else { };

  # a user's own theme wins over a shared one of the same name
  themes = shared // personal;

  chosen =
    if builtins.hasAttr name themes
    then themes.${name}
    else throw ''
      unknown theme "${name}"
      available: ${builtins.concatStringsSep ", " (builtins.attrNames themes)}
    '';

  # theme files are functions; apply to get the attrset of values
  selected = chosen { inherit pkgs; wallpapers = utils.wallpapers; };

  # fallbacks, each overridden by any theme that sets its own
  defaults = {
    fontMono  = "DejaVu Sans Mono";
    fontSans  = "DejaVu Sans";
    fontSerif = "DejaVu Serif";

    wallpaper = utils.wallpapers.default;
  };

  resolved = defaults // selected // {
    opacityHex = utils.toHex selected.opacity;
    opacityMin = utils.toHex 0.0;
    opacityMax = utils.toHex 1.0;
  };
  theme = resolved // {
    # `gtk` in a theme file stays the override block; this is the output
    gtkColors = import ./gtk.nix { inherit utils; } resolved;
  };
in
{
  imports = [ ./gtkApply.nix ./cursorApply.nix ];

  # available as `theme` in every other module of this user
  _module.args.theme = theme;
}
