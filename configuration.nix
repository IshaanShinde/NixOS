{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # enable networking
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
#--------------------------------------------------------------------------------------------------#
# Enable Wayland for Hyprland
#--------------------------------------------------------------------------------------------------#
  services.xserver.displayManager.gdm.wayland = true;
#--------------------------------------------------------------------------------------------------#

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.ishaan = {
    isNormalUser = true;
    description = "ishaan";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      #vim
    ];
  };

  nixpkgs.config.allowUnfree = true;

#--------------------------------------------------------------------------------------------------#
# Enable Flakes
#--------------------------------------------------------------------------------------------------#
  nix.settings.experimental-features = [ "nix-command" "flakes"];
#--------------------------------------------------------------------------------------------------#

  environment.systemPackages = with pkgs; [
    #vim
  ];
  
  system.stateVersion = "24.05";
  
#--------------------------------------------------------------------------------------------------#
# Nvidia
#--------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------#

}
