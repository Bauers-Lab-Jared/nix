moduleArgs@{
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
    ...
}:
with moduleArgs.lib.thisFlake;
let
  scope = mkFeatureScope {moduleFilePath = __curPos.file; inherit moduleArgs;};
in with scope;
let
  imports = with inputs; [
  ];

  featOptions = with types; {

  };

  featConfig = [(WITH_SYSTEM_FEAT_PATH {
    features = enableFeatList [
      "env-vars"
      "xdg"
      "sops"
    ];}) {

    i18n = {
        defaultLocale = mkDefault "en_US.UTF-8";
        supportedLocales = mkDefault [
        "en_US.UTF-8/UTF-8"
        ];
    };

    time.timeZone = mkDefault "US/Eastern";
    
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
  }];
in mkFeatureFile {inherit scope featOptions featConfig imports;}
