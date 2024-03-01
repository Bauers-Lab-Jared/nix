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
with lib.thisFlake; 
let
    cfg = config.thisFlake.sops;
in 
{
    options.thisFlake.sops = with types; 
    { 
        
    };

    config = {
        sops.defaultSopsFile = ./secrets/secrets.yaml;
        sops.defaultSopsFormat = "yaml";
        sops.age.keyFile = "/var/keys/sops.txt";

        sops.secrets.example-key = {};
        sops.secrets."myservice/my_subdir/my_secret" = {};
    };
}

#This module will be made available on your flake’s nixosModules,
# darwinModules, or homeModules output with the same name as the directory
# that you created.