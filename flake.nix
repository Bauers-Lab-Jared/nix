#https://nixos-and-flakes.thiscute.world/introduction/
#https://jdisaacs.com/blog/nixos-config/
#https://snowfall.org/guides/lib/quickstart/
rec {
  description = "Bauer's Lab Flake";

  inputs = {
    #secrets management
    #?   agenix.url = "github:ryantm/agenix";
    #modularizes deployment
    #?   deploy-rs.url = "github:serokell/deploy-rs";
    #Utilities for opt-in persistance
    impermanence.url = "github:riscadoa/impermanence";
    #adapts the nixos module system for config on individual users
    home-manager.url = "github:nix-community/home-manager";
    #the SOURCE
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #hardware config library
    hardware.url = "github:nixos/nixos-hardware";
    #utility functions for building flakes
    utils.url = "github:numtide/flake-utils";

    #provides a flake framework
    snowfall-lib = {
        url = "github:snowfallorg/lib";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    #simplified command line calls for flakes
    snowfall-flake = {
			url = "github:snowfallorg/flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

    #It's for a friend, I swear...
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    #When life gives you windows...
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    #Do you even vim, bruv?
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    #util.url = "path:./flake/util";
    #util.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: 
    inputs.snowfall-lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;

      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;

      # Configure Snowfall Lib, all of these settings are optional.
      snowfall = {
          # Tell Snowfall Lib to look in the `./nix/` directory for your
          # Nix files.
          root = ./nix;

          # Choose a namespace to use for your flake's packages, library,
          # and overlays.
          namespace = "thisFlake";

          # Add flake metadata that can be processed by tools like Snowfall Frost.
          meta = {
              # A slug to use in documentation when displaying things like file paths.
              name = "bauers-lab-flake";

              # A title to show for your flake, typically the name.
              title = "bauers-lab-flake";
          };
      };

      # The outputs builder receives an attribute set of your available NixPkgs channels.
      # These are every input that points to a NixPkgs instance (even forks). In this
      outputs-builder = channels: {
          # Outputs in the outputs builder are transformed to support each system. This
          # entry will be turned into multiple different outputs like `formatter.x86_64-linux.*`.
          # EX: formatter = channels.nixpkgs.alejandra;
      };
    };
}
