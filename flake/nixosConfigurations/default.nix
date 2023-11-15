{ inputs, lib, config, pkgs, ... }: with lib;
let
  inherit (config.thisConfig) systemName;
in { 

  imports = [ 
    ./configFeatures
    ../users
  ];

  system.name = mkDefault systemName;
  
  thisConfig = {
    features = [
      "home-manager"
      "git"
    ];
  };

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    supportedLocales = mkDefault [
      "en_US.UTF-8/UTF-8"
    ];
  };

  time.timeZone = mkDefault "US/Eastern";

  environment.systemPackages = with pkgs; [
    alejandra # Nix formatting tool
  ];
  
  # don't allow users to be created
  users.mutableUsers = mkDefault false;

  nix = {
    settings = {
      trusted-users = mkDefault [ "root" "@wheel" ];
      auto-optimise-store = mkDefault true;
      experimental-features = mkDefault [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = mkDefault false;
    };

    # Weekly garbage collection
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      # Keep the last 3 generations
      options = mkDefault "--delete-older-than +3";
    };
    
    # Enable optimisation
    optimise = {
      automatic = mkOverride 900 true;
      dates = mkDefault ["weekly"];
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  security.pam.services = mkDefault { swaylock = { }; };
  
  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}