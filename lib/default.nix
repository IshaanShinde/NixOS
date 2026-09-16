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

  # importable entries in dir, excluding default.nix: a `<name>.nix` file, or a `<name>/` holding one
  nixFilesIn = dir:
    let
      entries = builtins.readDir dir;

      isFile = name:
        entries.${name} == "regular"
        && name != "default.nix"
        && builtins.match ".*\\.nix" name != null;

      isDir = name:
        entries.${name} == "directory"
        && builtins.pathExists (dir + "/${name}/default.nix");

      names = builtins.attrNames entries;
    in
      map (name: builtins.head (builtins.match "(.*)\\.nix" name))
        (builtins.filter isFile names)
      ++ builtins.filter isDir names;

  # collects the wallpaper images in ../wallpapers by name
  wallpapers =
    let
      dir = ../wallpapers;

      entries = builtins.readDir dir;

      isImage = name:
        entries.${name} == "regular"
        && builtins.match ".*\\.(png|jpg|jpeg|webp)" name != null;

      # filename minus extension
      stem = name: builtins.head (builtins.match "(.*)\\.[^.]+" name);

      names = builtins.filter isImage (builtins.attrNames entries);

      byName = builtins.listToAttrs (map (name: {
        name = stem name;
        # copies to the store, as a path string
        value = "${dir + "/${name}"}";
      }) names);
    in
      byName // {
        # used when a theme names no wallpaper
        default =
          if byName ? windows-xplosion
          then byName.windows-xplosion
          else throw ''
            lib/default.nix: wallpapers.default points at "windows-xplosion",
            which is not in ${toString dir}
            available: ${builtins.concatStringsSep ", " (builtins.attrNames byName)}
          '';
      };

  # { <name> = import <the entry>; } for every importable entry in dir
  # passed through unapplied; a file evaluating to a function is the caller's to apply
  importNixFilesIn = dir:
    builtins.listToAttrs (map (name: {
      inherit name;
      value =
        let file = dir + "/${name}.nix";
        in import (if builtins.pathExists file then file else dir + "/${name}");
    }) (nixFilesIn dir));
}
