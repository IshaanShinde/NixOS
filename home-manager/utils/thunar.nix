{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunar
    tumbler
    ffmpegthumbnailer
    webp-pixbuf-loader
  ];
}
