{ pkgs, hyprland, ... }:

{
  
  imports = [
    hyprland.homeManagerModules.default
    ./programs
  ];
  
  home = {
    username = "ishaan";
    homeDirectory = "/home/ishaan";
    stateVersion = "24.11";
  };
  
  home.packages = with pkgs; [
    # user applications
    brave
    discord
    
    # utils
    git
    vim
    vscode
    
    zip
    unzip
    
    wget    
  ];
  
  programs.home-manager.enable = true;
  
}
