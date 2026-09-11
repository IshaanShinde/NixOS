# Apple fonts, fetched directly from Apple's CDN (the same downloads as
# https://developer.apple.com/fonts). Nothing is redistributed: each build
# downloads the official .dmg from Apple and unpacks it locally.
#
# The .dmg is a disk image containing a .pkg (xar archive), which contains
# a gzipped Payload, which is a cpio archive holding the actual .otf files.
# 7zz understands every layer, hence the repeated extraction.
#
# License: Apple's font license permits use for Apple-platform design work
# and mockups only; marked unfree so these never land in a binary cache.
{ lib, stdenvNoCC, fetchurl, _7zz }:

let
  mkAppleFont = { pname, url, hash }:
    stdenvNoCC.mkDerivation {
      inherit pname;
      version = "2026-07-18"; # date the hash was pinned

      src = fetchurl { inherit url hash; };

      nativeBuildInputs = [ _7zz ];

      unpackPhase = ''
        runHook preUnpack
        7zz x $src
        7zz x */*.pkg
        7zz x */Payload
        7zz x Payload~
        runHook postUnpack
      '';

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/fonts/opentype
        cp Library/Fonts/* $out/share/fonts/opentype/
        runHook postInstall
      '';

      meta = {
        description = "${pname} font from Apple";
        homepage = "https://developer.apple.com/fonts/";
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
      };
    };
in
{
  sf-pro = mkAppleFont {
    pname = "sf-pro";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    hash = "sha256-YxGk8IQ6TS5hagsFx3US0x0uqVBFnPUmzbW5CZageU8=";
  };

  sf-mono = mkAppleFont {
    pname = "sf-mono";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
  };

  sf-compact = mkAppleFont {
    pname = "sf-compact";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    hash = "sha256-/lF6UYS+KQ5m/om4tLbqGFSPztGuFTlJmnEmXjMXJJ8=";
  };

  new-york = mkAppleFont {
    pname = "new-york";
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
  };
}
