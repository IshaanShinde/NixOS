{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunar
    thunar-volman
    tumbler
    ffmpegthumbnailer
    webp-pixbuf-loader
    ntfs3g
  ];
}
