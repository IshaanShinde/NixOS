{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    logseq
    claude-code
    awscli2
    nomachine-client
  ];
}
