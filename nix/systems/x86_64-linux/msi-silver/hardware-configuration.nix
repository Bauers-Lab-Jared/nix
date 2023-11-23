{ config, lib, pkgs, inputs, ... }: let
  inherit (inputs) nixos-hardware;
in {
  imports = with nixos-hardware.nixosModules; [ 
      common-cpu-intel
      common-gpu-nvidia-nonprime
      common-hidpi
      common-pc-laptop
      common-pc-laptop-ssd
      common-pc-laptop-acpi_call
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/46adb894-757e-4264-a4dd-fd043f48271b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/84D5-D944";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/15dbccd6-f5d0-4d06-b379-f5f699c16a58"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
