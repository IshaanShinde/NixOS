{ ... }:

{
    programs.bash = {
        enable = true;
        shellAliases = {
            # nixos
            rt = "sudo nixos-rebuild test --flake /etc/nixos";
            rs = "sudo nixos-rebuild switch --flake /etc/nixos";
            
            # git
            g = "git";
            ga = "git add .";
            gc = "git commit -m";
            gp = "git push origin";
        };
    };
}
