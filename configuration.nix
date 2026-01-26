{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lisbeth";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";  

  users.users.ishaan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  security.polkit.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable       = true;
    alsa.enable  = true;
    pulse.enable = true;
  };
 
  nixpkgs.config.allowUnfree = true; 
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    hyprpaper
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.11"; # Did you read the comment?

}

