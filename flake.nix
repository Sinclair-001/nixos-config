# /etc/nixos/flake.nix
{
  description = "Kagan's NixOS — Secure Boot, MangoWM, Noctalia Shell v5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, mangowm, noctalia,
              zen-browser, nix-alien, helium-browser, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          helium-browser.overlays.default
          (final: prev: {
            openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
          })
        ];
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs system; };

        modules = [
          ./hosts/default/hardware-configuration.nix
          ./hosts/default/configuration.nix

          ./modules/core.nix
          ./modules/desktop.nix
          ./modules/hardware-nvidia.nix
          ./modules/audio.nix
          ./modules/gaming.nix
          ./modules/network.nix

          lanzaboote.nixosModules.lanzaboote
          mangowm.nixosModules.mango

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs    = true;
            home-manager.useUserPackages  = true;
            home-manager.extraSpecialArgs = { inherit inputs system; };
            home-manager.users.kagan      = import ./modules/home.nix;
            home-manager.sharedModules    = [
              mangowm.hmModules.mango
              noctalia.homeModules.default
            ];
          }
        ];
      };
    };
}
