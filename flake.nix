{
  description = "lisbeth -> nixos + hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Separate nixpkgs for claude-code - update independently with:
    # nix flake lock --update-input nixpkgs-claude
    nixpkgs-claude.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-claude, home-manager, ... }:
  let
    system = "x86_64-linux";
    utils = import ./lib { };
    mkTheme = import ./home-manager/themes { inherit utils; };
    # our own packages, as pkgs.<name> everywhere (see derivations/default.nix)
    ourPkgs = import ./derivations { inherit utils; };
    pkgs-claude = import nixpkgs-claude {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "claude-code"
      ];
    };
  in
  {
    nixosConfigurations.lisbeth = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        # useGlobalPkgs below means home-manager shares this pkgs, so one
        # overlay here reaches system modules and user modules alike
        { nixpkgs.overlays = [ ourPkgs ]; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # values injected into every user module
          home-manager.extraSpecialArgs = {
            inherit pkgs-claude utils mkTheme;
          };
          home-manager.users.ishaan = import ./home-manager/users/ishaan;
        }
      ];
    };
  };
}
