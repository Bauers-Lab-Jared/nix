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
  # All other arguments come from the system system.
  config,
  ...
}:
with lib;
with lib.thisFlake; let
  mainUser = "waffle";
  systemName = baseNameOf (toString ./.);
in {
  config = mkMerge [(WITH_SYSTEM_FEAT_PATH {
    features = {
      hw-configs.selectedConfig = "wsl";
      networking.networkLocation = "grc";
    } // enableFeatList [
      "openssh"
      "hw-configs"
    ];
    featSets = enableFeatList [
      
    ];
    systemDefs = enableFeatList [
      "wsl"
      "cli-workstation"
    ];#
    }) {
    thisFlake = {
      users.${mainUser} = {
        name = mainUser;
        fullName = mainUser;
        initialPassword = "change-it";
        email = "${mainUser}@${systemName}";
        extraGroups = [
          "wheel"
          "storage"
        ];
      };

      thisConfig = {
        inherit systemName mainUser;
      };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  }];
}
#This system will be made available on your flake’s nixosConfigurations,
# darwinConfigurations, or one of Snowfall Lib’s virtual *Configurations outputs
# with the same name as the directory that you created.

