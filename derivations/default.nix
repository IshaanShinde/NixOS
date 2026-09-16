{ utils }:

# every derivation in this directory, as a nixpkgs overlay, so they are reached
# as `pkgs.<name>` anywhere pkgs is in scope (system modules, home-manager
# modules, theme files) instead of `pkgs.callPackage ../../derivations/x.nix { }`
#
# a file here is one of two shapes:
#   - one package, added as `pkgs.<filename>`; nothing to declare, just add the
#     file (infinity-icon-theme.nix -> pkgs.infinity-icon-theme)
#   - a set of packages, which has to name them in `multi` below, each then
#     added under its own name (apple-fonts.nix -> pkgs.sf-pro, pkgs.sf-mono, ...)
#
# `multi` is written out rather than discovered because an overlay must say
# which attributes it defines *before* anything evaluates them; deriving the
# names from the packages would make the names depend on themselves.
let
  # <file in this directory> -> <the package names it contains>
  multi = {
    apple-fonts = [ "sf-pro" "sf-mono" "sf-compact" "new-york" ];
  };
in

final: prev:

let
  # { <filename-without-.nix> = <the unapplied function>; }
  files = utils.importNixFilesIn ./.;

  # `final.callPackage`, so a derivation here can depend on another one here
  # (and on anything in nixpkgs) without either being named explicitly
  called = builtins.mapAttrs (_: f: final.callPackage f { }) files;

  # one file's contribution, as a flat { <pkgname> = <derivation>; }
  entryOf = file:
    if multi ? ${file}
    then builtins.listToAttrs (map (n: { name = n; value = called.${file}.${n}; }) multi.${file})
    else { ${file} = called.${file}; };
in
  builtins.foldl' (a: b: a // b) { }
    (map entryOf (builtins.attrNames files))
