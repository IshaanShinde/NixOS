{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      # nixos
      rs = "sudo nixos-rebuild switch --flake /etc/nixos";
      ngc = "sudo nix-collect-garbage -d";
      nc = "cd /etc/nixos/";
      rebash = "source /home/ishaan/.bashrc";

      # git
      g  = "git";
      gs = "git status";
      gb = "git branch -v";
      gf = "git fetch --all";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push origin";

      # temp
      wr = "cd /home/ishaan/Documents/Repositories/TDS/; nix develop";
      wb = "cd /home/ishaan/Documents/Repositories/TDS/backend/; ENVIRONMENT=development uvicorn-hmr app:app --port 8001";
      wf = "cd /home/ishaan/Documents/Repositories/TDS/frontend/; npm run dev";
      agent = "aws sso login --profile claudeAgentTest";
    };
  };
}
