{ pkgs, ... }:

# docker with the gvisor (runsc) sandboxed runtime
{
  virtualisation.docker = {
    enable = true;
    extraOptions = "--add-runtime runsc=${pkgs.gvisor}/bin/runsc";
  };

  users.users.ishaan.extraGroups = [ "docker" ];
}
