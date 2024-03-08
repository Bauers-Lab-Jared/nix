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
with builtins;
let
    cfg = config.thisFlake.thisConfig;

    systemsMetaData = with lib.snowfall.fs; let
        allFiles = get-files-recursive (get-snowfall-file "systems");
        filteredFiles = filter (fp: hasSuffix "metadata.json" fp) allFiles;
        getMetaDataJson = name: let
            targetFile = findSingle 
                (fp: hasSuffix ("/${name}/metadata.json") fp)
                null
                (throw "Multiple metadata.json files found for system: ${name}") 
                filteredFiles;
        in if targetFile != null then fromJSON (readFile targetFile) 
            else {};
    in mapAttrs'
        (name: _: nameValuePair name (getMetaDataJson name)) systems;
in 
{
    options.thisFlake.thisConfig = with types; 
    { 
        mainUser = mkOpt str "nixos" "Primary user of this system";
        systemName = mkOpt str "nixos" "Name of this system";
        allSystems = mkOpt attrs systemsMetaData
            "an attribute set of all meta data imported from metadata.json in each system folder";
    };

    config = {

        networking = {
            hostName = cfg.systemName;
            domain = mkIf (cfg.allSystems ? ${cfg.systemName}.domain) cfg.allSystems.${cfg.systemName}.domain;
        };

    };
}

#This module will be made available on your flake’s nixosModules,
# darwinModules, or homeModules output with the same name as the directory
# that you created.