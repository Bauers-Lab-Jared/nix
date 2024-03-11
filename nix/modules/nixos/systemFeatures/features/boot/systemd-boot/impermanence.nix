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
    
  };

  featConfig = let
      root-reset-src = builtins.readFile (snowfall.fs.get-file "scripts/root-reset.sh");
      root-diff = pkgs.writeShellApplication {
        name = "root-diff";
        runtimeInputs = [ pkgs.btrfs-progs ];
        text = builtins.readFile (snowfall.fs.get-file "scripts/root-diff.sh");
      };
    in {

      boot.initrd.systemd.enable = true;
      boot.initrd.services.lvm.enable = true;
      boot.initrd.systemd.services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          # LUKS/TPM process
          "systemd-cryptsetup@enc.service"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = root-reset-src;
      };
      boot.initrd.systemd.services.persisted-files = {
        description = "Hard-link persisted files from /persist";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /sysroot/etc/
          ln -snfT /persist/etc/machine-id /sysroot/etc/machine-id
        '';
      };

    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    environment.systemPackages = lib.mkBefore [ root-diff ];
  };
in mkFeatureFile {inherit scope featOptions featConfig imports;}
