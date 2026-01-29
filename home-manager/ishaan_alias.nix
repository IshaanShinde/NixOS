{ ... }:

{
    programs.bash = {
        enable = true;
        shellAliases = {
            # nixos
            rs = "sudo nixos-rebuild switch --flake /etc/nixos";
            
            ngc = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10 && sudo nix-collect-garbage";
            ngca = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations && sudo nix-collect-garbage";

            # git
            g = "git";
            ga = "git add .";
            gc = "git commit -m";
            gp = "git push origin";
        };
    };
}
