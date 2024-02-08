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
  ...
}:
with lib;
with lib.thisFlake; let
  featureName = baseNameOf (toString ./.);
  cfg = config.thisFlake.configFeatures.${featureName};
in {
  imports = [
  ];

  options = mkConfigFeature {
    inherit config featureName;
    otherOptions = with types; {
      thisFlake.configFeatures.${featureName} = {
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      libfido2
    ];

    services = {
      #yubikey-agent.enable = true;

      pcscd.enable = true;

      udev = {
        enable = true;
        packages = [pkgs.yubikey-personalization];
        extraRules = ''
          SUBSYSTEM=="usb", MODE="0666"
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
        '';
      };
    };
  };
}
