{ pkgs, ... }:

{
  imports = [
    ./ags.nix
  ];

  home.packages = with pkgs; [
    ags
    astal.io
    astal.astal3
    astal.apps
    astal.network
    astal.bluetooth
    astal.wireplumber
    astal.hyprland
  ];
}
