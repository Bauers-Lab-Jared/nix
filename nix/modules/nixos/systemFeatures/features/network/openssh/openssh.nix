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
  inherit (config.networking) hostName;
  hosts = systems;
  pubKey = host: (
    snowfall.fs.get-snowfall-file 
    "systems/${systems.${host}.system}/${host}/ssh_host_ed25519_key.pub");
  
  usePersistPath = (cfgHasFeat' "sops") && (cfgHasFeat' "impermanence");  

  imports = with inputs; [
  ];

  featOptions = with types; {

  };

  featConfig = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      settings = {
        # Harden
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        # Automatically remove stale sockets
        StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        GatewayPorts = "clientspecified";
      };

      hostKeys = [{
        # Sops needs acess to the keys before the persist dirs are even mounted;
        path = (optionalString usePersistPath PERSIST_SYSTEM)
          + "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
    };

    programs.ssh = {
    # Each hosts public key
      knownHosts = mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          (lib.optional (name == hostName) "localhost");
      })
      hosts;
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCfau/nsDvu2ryn4QDaLLCdzREXeZ7pUL6zuzTNYfwh waffle@waffle"
    ];
    users.users.waffle.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCfau/nsDvu2ryn4QDaLLCdzREXeZ7pUL6zuzTNYfwh waffle@waffle"
    ];

    security.pam.enableSSHAgentAuth = true;
    security.sudo.wheelNeedsPassword = false;
    services.openssh.authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
  };
in mkFeatureFile {inherit scope featOptions featConfig imports;}
