{ pkgs, mkTheme, ... }:

let
  # tetrio-desktop (Electron) never paints on NVIDIA + Wayland: the GPU process can't allocate
  # GBM buffers ("Cannot create bo ... usage=SCANOUT")
  # wrapped so the flag applies however it's launched (shell, rofi, ...)
  tetrio-desktop-wrapped = pkgs.symlinkJoin {
    name = "tetrio-desktop-wrapped";
    paths = [ pkgs.tetrio-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/tetrio \
        --add-flags "--disable-gpu-compositing"

      # the .desktop Exec= hard-codes the unwrapped store path; repoint it
      rm -f $out/share/applications/TETR.IO.desktop
      substitute ${pkgs.tetrio-desktop}/share/applications/TETR.IO.desktop \
        $out/share/applications/TETR.IO.desktop \
        --replace ${pkgs.tetrio-desktop}/bin/tetrio $out/bin/tetrio
    '';
  };
in
{
  imports = [
    # this user's theme, resolved from ./themes then the shared presets
    (mkTheme {
      name = "custom";
      userThemes = ./themes;
    })

    ./hyprland
    ./tools
    ./development
    ./shell.nix
  ];

  home.username = "ishaan";
  home.homeDirectory = "/home/ishaan";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # already in configuration.nix
    # git
    # vim
    # wget
    # firefox
    # openrgb-with-all-plugins

    # base
    zip
    unzip

    # nixos
    fastfetch

    # browsers
    brave
    vivaldi
    google-chrome

    # communication
    discord
    signal-desktop

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
