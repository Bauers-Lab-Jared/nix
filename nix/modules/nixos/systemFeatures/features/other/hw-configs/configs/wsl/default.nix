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
  configName = baseNameOf (toString ./.);
  cfg = (FROM_SYSTEM_FEAT_PATH config).features.hw-configs;
  activate = cfg.enable && (cfg.selectedConfig == configName);
in
{
  config = mkIf activate {
    boot.initrd.availableKernelModules = [ "virtio_pci" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = { 
      device = "/dev/sdc";
      fsType = "ext4";
    };

    fileSystems."/mnt/wsl" =
    { device = "none";
      fsType = "tmpfs";
    };

    fileSystems."/usr/lib/wsl/drivers" =
      { device = "none";
        fsType = "9p";
      };

    fileSystems."/mnt/wslg" =
      { device = "none";
        fsType = "tmpfs";
      };

    fileSystems."/mnt/wslg/distro" =
      { device = "";
        fsType = "none";
        options = [ "bind" ];
      };

    fileSystems."/usr/lib/wsl/lib" =
      { device = "none";
        fsType = "overlay";
      };

    fileSystems."/mnt/wslg/.X11-unix" =
      { device = "/mnt/wslg/.X11-unix";
        fsType = "none";
        options = [ "bind" ];
      };

    fileSystems."/mnt/c" =
      { device = "drvfs";
        fsType = "9p";
      };

    fileSystems."/mnt/wslg/doc" =
      { device = "none";
        fsType = "overlay";
      };

    fileSystems."/mnt/d" =
      { device = "drvfs";
        fsType = "9p";
      };

    swapDevices =
      [ { device = "/dev/sdb"; }
      ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.bonding_masters.useDHCP = lib.mkDefault true;
    # networking.interfaces.eth0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}