#https://nixos-and-flakes.thiscute.world/introduction/
#https://jdisaacs.com/blog/nixos-config/
#https://snowfall.org/guides/lib/quickstart/
#https://github.com/jakehamilton/config
{
  description = "Bauer's Lab Flake";

  inputs = rec {
    #The SOURCE
    nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = nixpkgs-unstable;

    #provides a flake framework
    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=v2.1.1";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };

    #provides a set of sub module systems for handling each home
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-23_11";

    # Hardware Configuration Library
    nixos-hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs-23_11";

    #simplified command line calls for flakes
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #When life gives you windows...
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };

    # System Deployment
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # This hosts a nix binary cache in a S3
    # Provider, which can be hosted with ceph
    # attic = {
    #   url = "github:zhaofengli/attic";
    #   inputs.nixpkgs.follows = "unstable";
    #   inputs.nixpkgs-stable.follows = "nixpkgs";
    # };

    # # Hashicorp Vault Integration (secrets management)
    # vault-service = {
    #   url = "github:DeterminateSystems/nixos-vault-service";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # # Flake Hygiene
    # flake-checker = {
    #   url = "github:DeterminateSystems/flake-checker";
    #   inputs.nixpkgs.follows = "unstable";
    # };

    # # Discord Replugged
    # replugged.url = "github:LunNova/replugged-nix-flake";
    # replugged.inputs.nixpkgs.follows = "unstable";

    # # Discord Replugged plugins / themes
    # discord-tweaks = {
    #   url = "github:NurMarvin/discord-tweaks";
    #   flake = false;
    # };
    # discord-nord-theme = {
    #   url = "github:DapperCore/NordCord";
    #   flake = false;
    # };

    # # Yubikey Guide
    # yubikey-guide = {
    #   url = "github:drduh/YubiKey-Guide";
    #   flake = false;
    # };

    # # GPG default configuration
    # gpg-base-conf = {
    #   url = "github:drduh/config";
    #   flake = false;
    # };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
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
          title = "Bauer's Lab Flake";
        };
      };
    };
  in
    lib.mkFlake {
      channels-config.allowUnfree = true;

      overlays = with inputs; [
        snowfall-flake.overlays.default
        #attic.overlays.default
      ];

      # modules to apply to all nixos systems
      systems.modules.nixos = with inputs; [
        # nix-ld.nixosModules.nix-ld
        # attic.nixosModules.atticd
      ];

      deploy = lib.mkDeploy {inherit (inputs) self;};

      checks =
        builtins.mapAttrs
        (system: deploy-lib:
          deploy-lib.deployChecks inputs.self.deploy)
        inputs.deploy-rs.lib;
    };
}
