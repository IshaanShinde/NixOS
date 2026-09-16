{ utils }:

# every derivation in this directory, as a nixpkgs overlay -> pkgs.<name>
#
# a file holding one package is added as pkgs.<filename>; a file holding a set must name them in `multi` below
# (an overlay has to declare its attribute names before anything evaluates them, so they can't be discovered)
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

  # final.callPackage, so a derivation here can depend on another one here
  called = builtins.mapAttrs (_: f: final.callPackage f { }) files;

  # one file's contribution, as a flat { <pkgname> = <derivation>; }
  entryOf = file:
    if multi ? ${file}
    then builtins.listToAttrs (map (n: { name = n; value = called.${file}.${n}; }) multi.${file})
    else { ${file} = called.${file}; };
in
  builtins.foldl' (a: b: a // b) { }
    (map entryOf (builtins.attrNames files))
