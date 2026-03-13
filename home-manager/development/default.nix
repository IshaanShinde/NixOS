{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./vscode.nix
    ./claude.nix
  ];

  home.packages = with pkgs; [
    logseq
    awscli2
    nomachine-client
    poppler-utils # pdf handling
  ];
}
