{ }:

# utils shared across the config; builtins only, no nixpkgs lib
rec {
  # 0.67 -> "ab"; a 0.0-1.0 ratio as a 2-digit lowercase hex byte
  toHex = ratio:
    let
      digits = "0123456789abcdef";
      byte = builtins.floor (ratio * 255);
      high = byte / 16;
      low = byte - (high * 16);
    in
      "${builtins.substring high 1 digits}${builtins.substring low 1 digits}";

  # names of the .nix files in dir, without the suffix, excluding default.nix
  nixFilesIn = dir:
    let
      entries = builtins.readDir dir;
      isModule = name:
        entries.${name} == "regular"
        && name != "default.nix"
        && builtins.match ".*\\.nix" name != null;
    in
      map (name: builtins.head (builtins.match "(.*)\\.nix" name))
        (builtins.filter isModule (builtins.attrNames entries));

  # { <name> = import dir/<name>.nix; } for every .nix file in dir
  importNixFilesIn = dir:
    builtins.listToAttrs (map (name: {
      inherit name;
      value = import (dir + "/${name}.nix");
    }) (nixFilesIn dir));
}
