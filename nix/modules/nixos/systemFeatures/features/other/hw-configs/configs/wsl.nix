scope:
with scope;
with lib;
with lib.thisFlake; 
#let

  # hasImpermanence = systemHasFeat "features" "impermanence";

  # impermanenceConfig = mkMerge [(mkIf hasImpermanence 
  # {
  #   fileSystems."/" = {
  #     device = "none";
  #     fsType = "tmpfs";
  #     options = [ "defaults" "size=25%" "mode=755" ];
  #   };

  #   fileSystems."/persistent" = { 
  #     device = "/dev/sdc";
  #     fsType = "ext4";
  #   };

  #   fileSystems."/etc/nixos" =
  #   { device = "/persistent/etc/nixos";
  #     fsType = "none";
  #     options = [ "bind" ];
  #   };

  #   fileSystems."/var/log" =
  #   { device = "/persistent/var/log";
  #     fsType = "none";
  #     options = [ "bind" ];
  #   };

  #   fileSystems."/nix" =
  #   { device = "/persistent/nix";
  #     fsType = "none";
  #     options = [ "bind" ];
  #   };
  # })

  # (mkIf (!hasImpermanence)
  # {
  #   fileSystems."/" = { 
  #     device = "/dev/sdc";
  #     fsType = "ext4";
  #   };
  # })];

#in 
{
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
}