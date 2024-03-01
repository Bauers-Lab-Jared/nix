#https://nixos-and-flakes.thiscute.world/introduction/
#https://jdisaacs.com/blog/nixos-config/
#https://snowfall.org/guides/lib/quickstart/
#https://github.com/jakehamilton/config
{
  description = "Bauer's Lab Flake";

  inputs = {
    #The SOURCE
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #provides a flake framework
    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=v2.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #provides a set of sub module systems for handling each home
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware Configuration Library
    nixos-hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
       url = "github:nix-community/impermanence";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    #simplified command line calls for flakes
    snowfall-flake = {
      url = "github:snowfallorg/flake?ref=v1.1.0";
      inputs.nixpkgs.follows = "unstable";
    };

    snowfall-thaw = {
      url = "github:snowfallorg/thaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake.url = "github:bauers-lab-jared/neovim-flake?ref=main-dev";

    #It's for a friend, I swear...
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "unstable";
    };

    #When life gives you windows...
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #allows you to run a command from nixpkgs
    #in a single use shell. EX: ", cowsay neato"
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "unstable";

    # System Deployment
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "unstable";

    # Run unpatched dynamically compiled binaries
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "unstable";

    # This hosts a nix binary cache in a S3
    # Provider, which can be hosted with ceph
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

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
          title = "Bauer's Lab Flake";
        };
      };

      channels-config.allowUnfree = true;

      overlays = with inputs; [
        snowfall-thaw.overlays.default
        snowfall-flake.overlays.default
        #attic.overlays.default
      ];

      # modules to apply to all nixos systems
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        # nix-ld.nixosModules.nix-ld
        # attic.nixosModules.atticd
      ];

      deploy = inputs.lib.mkDeploy {inherit (inputs) self;};

      checks =
        builtins.mapAttrs
        (system: deploy-lib:
          deploy-lib.deployChecks inputs.self.deploy)
        inputs.deploy-rs.lib;

      # The outputs builder receives an attribute set of your available NixPkgs channels.
      # These are every input that points to a NixPkgs instance (even forks). In this
      outputs-builder = channels: {
        # Outputs in the outputs builder are transformed to support each system. This
        # entry will be turned into multiple different outputs like `formatter.x86_64-linux.*`.
        # EX: formatter = channels.nixpkgs.alejandra;
      };
    };
}
