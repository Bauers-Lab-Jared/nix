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
  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules = [ 
      "virtio_net"
      "virtio_mmio"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    boot.initrd.kernelModules = [ 
      "dm-snapshot"
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable)
    ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';
  };
}