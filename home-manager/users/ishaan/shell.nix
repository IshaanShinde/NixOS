{ ... }:

let
  # machine-local aliases, gitignored; see .private_aliases.example
  privateAliases =
    if builtins.pathExists ./.private_aliases
    then import ./.private_aliases
    else { };
in
{
  programs.bash = {
    enable = true;
    shellAliases = privateAliases // {
      # nixos
      rs = "sudo nixos-rebuild switch --flake /etc/nixos";
      ngc = "sudo nix-collect-garbage -d";
      nc = "cd /etc/nixos/";
      rebash = "source $HOME/.bashrc";

      # git
      g  = "git";
      gs = "git status";
      gb = "git branch -v";
      gf = "git fetch --all";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push origin";
    };
  };
}
