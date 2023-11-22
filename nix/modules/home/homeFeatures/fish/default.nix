{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # An instance of `pkgs` with your overlays and packages applied is also available.
    pkgs,
    # You also have access to your flake's inputs.
    inputs,

    # Additional metadata is provided by Snowfall Lib.
    system, # The system architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
    format, # A normalized name for the system target (eg. `iso`).
    virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
    systems, # An attribute map of your defined hosts.

    # All other arguments come from the module system.
    config,
    osConfig,
    ...
}: with lib;
with lib.thisFlake;
let
  featureName = baseNameOf (toString ./.);
  cfg = config.thisFlake.homeFeatures.${featureName};
  hasFeat = lib.thisFlake.hasFeat {inherit osConfig;};
  hasNeovim = hasFeat "nvim";
in {

  imports = [      
    
  ];

  options = mkHomeFeature {inherit osConfig featureName; otherOptions = {
      homeFeatures.${featureName} = {
        
      };
    };
  };
  
  config = mkIf cfg.enable {
    programs.fish = {
      enable = mkDefault true;

      shellAbbrs = mkDefault rec {
        jqless = "jq -C | less -r";

        n = "nix";
        nd = "nix develop -c $SHELL";
        ns = "nix shell";
        nsn = "nix shell nixpkgs#";
        nb = "nix build";
        nbn = "nix build nixpkgs#";
        nf = "nix flake";

        nr = "nixos-rebuild --flake .";
        nrs = "nixos-rebuild --flake . switch";
        snr = "sudo nixos-rebuild --flake .";
        snrs = "sudo nixos-rebuild --flake . switch";
        hm = "home-manager --flake .";
        hms = "home-manager --flake . switch";

        vim = mkIf hasNeovim "nvim";
        vi = vim;
        v = vim;
      };
      shellAliases = mkDefault {
        # Clear screen and scrollback
        clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      };
      functions = mkDefault {
        # Disable greeting
        fish_greeting = "echo This is the fish shell with some general configuration.";
      };
    };
  };
}

#This module will be made available on your flake’s nixosModules,
# darwinModules, or homeModules output with the same name as the directory
# that you created.