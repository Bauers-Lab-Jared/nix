#https://nixos-and-flakes.thiscute.world/introduction/
#https://jdisaacs.com/blog/nixos-config/
rec {
  description = "Bauer's Lab Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Utilities for building our flake
    flake-utils.url = "github:numtide/flake-utils";

    util.url = "path:./flake/util";
    util.inputs.nixpkgs.follows = "nixpkgs";
    # Extra flakes for modules, packages, etc
    hardware.url = "github:nixos/nixos-hardware"; # Convenience modules for hardware-specific quirks
    # nur.url = "github:nix-community/NUR"; # User contributed pkgs and modules
    # nix-colors.url = "github:misterio77/nix-colors"; # Color schemes for usage with home-manager
    # impermanence.url = "github:riscadoa/impermanence"; # Utilities for opt-in persistance
    # agenix.url = "github:ryantm/agenix"; # Secrets management

     # Window manager
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprland-contrib = {
    #   url = "github:hyprwm/contrib";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ... } @ inputs: let 
    inherit (self) outputs;
  in 
  ( import ./flake {inherit inputs outputs;} );
  
}
