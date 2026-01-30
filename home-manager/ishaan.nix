{ pkgs, ... }:

{
  imports = [
    ./hyprland
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

    # browsers
    brave
    firefox # fallback     

    # communication
    discord
    signal-desktop

    # hyprland
    foot
    wofi
    dunst    
    
    # file manager
    thunar
    tumbler               # thumbnail service
    ffmpegthumbnailer     # video thumbnails
    webp-pixbuf-loader    # webp support    
    
    # dev
    logseq
    vscode
    vscode-extensions.anthropic.claude-code
    claude-code
    # cloud
    awscli2
  ];
  
  programs.git = {
      enable = true;
      settings.user.name  = "IshaanShinde";
      settings.user.email = "ishaanshinde08@gmail.com";
  };

  programs.home-manager.enable = true;
}
  