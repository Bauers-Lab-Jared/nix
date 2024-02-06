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
  usbipd-win-auto-attach = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dorssel/usbipd-win/v3.1.0/Usbipd/wsl-scripts/auto-attach.sh";
    hash = "sha256-KJ0tEuY+hDJbBQtJj8nSNk17FHqdpDWTpy9/DLqUFaM=";
  };
in {
  imports = [
  ];

  options = mkConfigFeature {
    inherit config featureName;
    otherOptions = with types; {
      thisFlake.configFeatures.${featureName} = {
        autoAttach = mkOption {
          type = listOf str;
          default = [];
          example = ["4-1"];
          description = "Auto attach devices with provided Bus IDs.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.linuxPackages.usbip
      pkgs.yubikey-manager
      pkgs.libfido2
    ];

    services.pcscd.enable = true;
    services.udev = {
      enable = true;
      packages = [pkgs.yubikey-personalization];
      extraRules = ''
        SUBSYSTEM=="usb", MODE="0666"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
      '';
    };

    systemd = {
      services."usbip-auto-attach@" = {
        description = "Auto attach device having busid %i with usbip";
        after = ["network.target"];

        scriptArgs = "%i";
        path = [pkgs.linuxPackages.usbip];

        script = ''
          busid="$1"
          ip="$(grep nameserver /etc/resolv.conf | cut -d' ' -f2)"

          echo "Starting auto attach for busid $busid on $ip."
          source ${usbipd-win-auto-attach} "$ip" "$busid"
        '';
      };

      targets.multi-user.wants = map (busid: "usbip-auto-attach@${busid}.service") cfg.autoAttach;
    };
  };
}
