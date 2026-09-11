{ utils }:

# resolves a theme name against the shared themes here plus the user's own dir
{ name, userThemes ? null }:

let
  shared = utils.importNixFilesIn ./.;

  personal =
    if userThemes != null && builtins.pathExists userThemes
    then utils.importNixFilesIn userThemes
    else { };

  # a user's own theme wins over a shared one of the same name
  themes = shared // personal;

  selected =
    if builtins.hasAttr name themes
    then themes.${name}
    else throw ''
      unknown theme "${name}"
      available: ${builtins.concatStringsSep ", " (builtins.attrNames themes)}
    '';

  # fallback fonts, overridden by any theme that sets its own
  fontDefaults = {
    fontMono  = "DejaVu Sans Mono";
    fontSans  = "DejaVu Sans";
    fontSerif = "DejaVu Serif";
  };
in
  fontDefaults // selected // {
    opacityHex = utils.toHex selected.opacity;
    opacityMin = utils.toHex 0.0;
    opacityMax = utils.toHex 1.0;
  }
