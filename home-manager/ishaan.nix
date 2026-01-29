{ config, pkgs, ... }:

{
    imports = [ ./hyprland.nix ./ishaan_alias.nix ];

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
        # fallback
        firefox 

        # communication
        discord
        signal-desktop
        
        # hyprland
        foot
        wofi
        # waybar
        hyprpaper
        dunst

        # dev
        logseq
        vscode
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
