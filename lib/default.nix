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

  # names of the importable entries in dir, excluding default.nix itself:
  # a `<name>.nix` file, or a `<name>/` directory holding its own default.nix
  # (both import the same way, so a thing can grow from one file into a
  # directory of files without anything that reads it changing)
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

      # strips the file extension off a filename
      stem = name: builtins.head (builtins.match "(.*)\\.[^.]+" name);

      names = builtins.filter isImage (builtins.attrNames entries);

      byName = builtins.listToAttrs (map (name: {
        name = stem name;
        # copies the file to the store and takes its path as a string
        value = "${dir + "/${name}"}";
      }) names);
    in
      byName // {
        # the wallpaper used when a theme names none
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
  # `<name>.nix` if that file exists, else the `<name>/` directory, which nix
  # imports as its default.nix
  # whatever the file evaluates to is passed through as-is; if it is a function
  # (theme files are) the caller is the one that applies it
  importNixFilesIn = dir:
    builtins.listToAttrs (map (name: {
      inherit name;
      value =
        let file = dir + "/${name}.nix";
        in import (if builtins.pathExists file then file else dir + "/${name}");
    }) (nixFilesIn dir));
}
