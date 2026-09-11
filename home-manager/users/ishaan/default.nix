{ pkgs, mkTheme, ... }:

let
  # tetrio-desktop (Electron) fails to paint on NVIDIA + Wayland: the GPU
  # process can't allocate GBM buffers ("Cannot create bo ... usage=SCANOUT"),
  # the GL context is lost immediately, and no window ever appears. Disabling
  # GPU compositing sidesteps it. Wrap the package so the `tetrio` command
  # always carries the flag, regardless of how it's launched (shell, rofi, ...).
  tetrio-desktop-wrapped = pkgs.symlinkJoin {
    name = "tetrio-desktop-wrapped";
    paths = [ pkgs.tetrio-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/tetrio \
        --add-flags "--disable-gpu-compositing"

      # The .desktop file (used by the app menu) hard-codes the unwrapped
      # store path in Exec=, bypassing the wrapper. Repoint it at ours.
      rm -f $out/share/applications/TETR.IO.desktop
      substitute ${pkgs.tetrio-desktop}/share/applications/TETR.IO.desktop \
        $out/share/applications/TETR.IO.desktop \
        --replace ${pkgs.tetrio-desktop}/bin/tetrio $out/bin/tetrio
    '';
  };
in
{
  imports = [
    ./hyprland
    ./tools
    ./development
    ./shell.nix
  ];

  # this user's theme, resolved from ./themes then the shared ones
  _module.args.theme = mkTheme {
    name = "custom";
    userThemes = ./themes;
  };

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
    vivaldi
    firefox
    google-chrome

    # communication
    discord
    signal-desktop

    # rgb
    openrgb-with-all-plugins

    # other
    spotify
    tetrio-desktop-wrapped
    clock-rs
    peaclock

    # audio
    sox
  ];
  
  programs.home-manager.enable = true;
}
