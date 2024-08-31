{
  description = "NixOs Configuration + Home Manager + Hyprland";

  inputs = {
    # nixos
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    

  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:
    
    let 
      system = "x86_64-linux";
      
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      
    in {
      nixosConfigurations = {
        # you change "ishaan" (flake name) based on your prefered nomenclature
        ishaan = nixpkgs.lib.nixosSystem rec {
        
          specialArgs = { 
            inherit system;
            inherit hyprland;
          };
          
          modules = [
            # nix config
            ./nixos/configuration.nix
            
            # home manager
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.ishaan = import ./home-manager/home.nix ;
              home-manager.extraSpecialArgs = specialArgs;
            } 
            
            # hyprland
            hyprland.nixosModules.default # { wayland.windowManager.hyprland.enable = true; }
          ];
          
        };
      };
    };

  }
