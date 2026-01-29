{ config, pkgs, ... }:

{
    imports = [ ./hyprland.nix ];

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

        vscode
        awscli2

        firefox # fallback
        
        # hyprland
        foot
        wofi
        waybar
        dunst

        claude-code

    ];

    programs.git = {
        enable = true;
        settings.user.name  = "IshaanShinde";
        settings.user.email = "ishaanshinde08@gmail.com";
    };
    programs.home-manager.enable = true;
}
