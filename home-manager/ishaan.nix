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
        kitty
        wofi
        waybar
        dunst

        claude-code

    ];

    programs.git.enable = true;
    programs.home-manager.enable = true;
}
