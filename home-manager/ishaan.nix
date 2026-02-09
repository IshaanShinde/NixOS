{ pkgs, ... }:

{
  imports = [
    ./hyprland
    ./utils
    ./development
    ./ishaan_alias.nix
  ];

  home.username = "ishaan";
  home.homeDirectory = "/home/ishaan";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # base
    git
    vim
    wget
    zip
    unzip

    # nixos
    fastfetch

    # browsers
    brave
    firefox

    # communication
    discord
    signal-desktop

    # other
    spotify
  ];

  programs.home-manager.enable = true;
}