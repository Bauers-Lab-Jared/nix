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
    hosts = mkOpt attrs { } "An attribute set to merge with `networking.hosts`";
    networkLocation = mkOpt' str "";
  };

  featConfig = mkMerge [{
    thisFlake.users.${config.thisFlake.thisConfig.mainUser}.extraGroups = 
      mkIf config.networking.networkmanager.enable [ "networkmanager" ];

    networking = {
      hosts = {
        "127.0.0.1" = [ "local.test" ] ++ (cfg.hosts."127.0.0.1" or [ ]);
      } // cfg.hosts;
    };

  } (mkIf (cfg.networkLocation == "grc") {
    networking = {
      nameservers = [ "10.131.245.1" ];
    };
  })];
in mkFeatureFile {inherit scope featOptions featConfig imports;}
