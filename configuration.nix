{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system/nixpkgs.nix

    # optional, remove to drop
    ./system/steam.nix
    ./system/docker.nix
  ];

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
    STEAM_FORCE_DESKTOPUI_SCALING = "2";
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

  services.hardware.openrgb.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

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
  
  programs.firefox.enable = true;

  # Cloudflare WARP (installs cloudflare-warp + enables warp-svc daemon)
  services.cloudflare-warp.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    cloudflare-warp
    gvisor
  ];

  fonts.packages = with pkgs; [
    # to avoid tofu
    noto-fonts
    noto-fonts-cjk-sans # chinese japanese korean
    noto-fonts-color-emoji
  ] ++ (with pkgs.callPackage ./derivations/apple-fonts.nix { }; [
    sf-pro
    sf-mono
    sf-compact
    new-york
  ]);

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.11"; # for the love of god please don't touch this >w<"

}

