{ utils }:

# resolves a theme name against ./presets plus the user's own dir
{ name, userThemes ? null }:

# returns a module, not an attrset, so `pkgs` arrives from the module system
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

  # theme files are functions of { pkgs, wallpapers }
  selected = chosen { inherit pkgs; wallpapers = utils.wallpapers; };

  # overridden by any theme that sets its own
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
    # the generated colors; `gtk` in a theme file stays the override block
    gtkColors = import ./gtk.nix { inherit utils; } resolved;
  };
in
{
  imports = [ ./gtkApply.nix ./cursorApply.nix ];

  # available as `theme` in every other module of this user
  _module.args.theme = theme;
}
