{ pkgs, ... }:

{
  imports = [
    ./hyprland
    ./utils
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
    firefox # fallback     

    # communication
    discord
    signal-desktop

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
      extraConfig.core.editor = "vim";
  };

  programs.home-manager.enable = true;
}
  