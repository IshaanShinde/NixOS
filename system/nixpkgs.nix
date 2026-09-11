{ lib, ... }:

{
  # unfree packages this system is allowed to build
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    # nvidia
    "nvidia-x11"
    "nvidia-settings"

    # editors / tooling
    "vscode"
    "vscode-extension-MS-python-vscode-pylance"
    "vscode-extension-anthropic-claude-code"
    "claude-code"

    # browsers
    "google-chrome"
    "vivaldi"

    # communication
    "discord"

    # steam
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"

    # media / games
    "spotify"
    "tetrio-desktop"

    # networking
    "nomachine-client"
    "cloudflare-warp"

    # apple fonts (fetched from Apple's CDN, see derivations/apple-fonts.nix)
    "sf-pro"
    "sf-mono"
    "sf-compact"
    "new-york"
  ];
}
