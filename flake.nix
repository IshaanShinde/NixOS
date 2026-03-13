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
    pkgs-claude = import nixpkgs-claude { inherit system; };
  in
  {
    nixosConfigurations.lisbeth = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit pkgs-claude; };
          home-manager.users.ishaan = import ./home-manager/ishaan.nix;
        }
      ];
    };
  };
}
