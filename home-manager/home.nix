{ config, pkgs, ... }:

{
  home = {
  username = "ishaan";
  homeDirectory = "/home/ishaan";
  stateVersion = "23.11";
  };
  
  # enable unfree packages
  nixpkgs.config.allowUnfree = true;
  
  home.packages = with pkgs; [
  
    # user applications
    discord
    brave
    
    
    # utils
    vim
    zip
    unzip
    wget
    vscode
    kitty
    efibootmgr
    
    # for hyprland
    xdg-desktop-portal-hyprland
  ];

  home.file = {
  };
  
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
#--------------------------------------------------------------------------------------------------#
  imports = [
    # hyprland
    ./modules/hyprland.nix
    
    # other
    ./modules/git.nix
  ];
#--------------------------------------------------------------------------------------------------#
}
