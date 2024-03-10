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
  configName = snowfall.path.get-file-name-without-extension __curPos.file;
  cfg = (FROM_SYSTEM_FEAT_PATH config).features.disko;
  activate = cfg.enable && (cfg.selectedConfig == configName);
in
{
  config = mkIf activate {
    disko.devices = {
      disk.main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "uid=0" "gid=0" "fmask=0077" "dmask=0077" ];
              };
            };
            swap = {
              size = "4G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      lvm_vg = {
        pool = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                subvolumes = {
                  "root" = {
                    mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    mountpoint = "/";
                  };

                  "persist" = {
                    mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                    mountpoint = "${PERSIST_BASE}";
                  };

                  "nix" = {
                    mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };

                  "log" = {
                    mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                    mountpoint = "${PERSIST_LOG}";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}