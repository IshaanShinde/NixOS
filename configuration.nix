{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;  # Recommended for RTX 40 series (Turing+)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Hyprland + NVIDIA compatibility
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";  # Wayland for Electron apps (VSCode, etc.)
  };

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
 
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"

    "vscode"
    "vscode-extension-anthropic-claude-code"
    "claude-code"
    "discord"
    
  ];

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  fonts.packages = with pkgs; [
    # to avoid tofu
    noto-fonts
    noto-fonts-cjk-sans # chinese japanese korean
    noto-fonts-color-emoji
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.11"; # Did you read the comment?

}

