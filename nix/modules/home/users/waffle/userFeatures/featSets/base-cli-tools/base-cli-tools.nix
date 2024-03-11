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
    osConfig,
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

  featConfig = mkMerge [(WITH_HOME_FEAT_PATH {
    features = enableFeatList [
      "neovim"
    ];
  }) {
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "mkkey";

        runtimeInputs = [ openssh ];

        text = ''
          mkfifo key && ( (cat key ; rm key)&) && (echo y | ssh-keygen -N "" -q -f key > /dev/null)
        '';
      })
    ];
  }];
in mkFeatureFile {inherit scope featOptions featConfig imports;}
