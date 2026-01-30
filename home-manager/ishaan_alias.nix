{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      # nixos
      rs = "sudo nixos-rebuild switch --flake /etc/nixos";
      ngc = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10 && sudo nix-collect-garbage";
      ngca = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations && sudo nix-collect-garbage";
      rebash = "source /home/ishaan/.bashrc";

      # git
      g  = "git";
      gs = "git status";
      gb = "git branch -v";
      gf = "git fetch --all";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push origin";

      wr = "cd /home/ishaan/Documents/Repositories/TDS/";
    };
  };
}
