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
    cfg = config.thisFlake.users;
in { #Define users here
    options.thisFlake.users = mkOption {
        type = with types; attrsOf (submodule {
            options = {
                name = mkOpt str "nixos" "The name to use for the user account.";
                fullName = mkOpt str "NixOS" "The full name of the user.";
                email = mkOpt str "nixos@nowhere.not" "The email of the user.";
                initialPassword = mkOpt str "" "";
                icon = mkOpt (nullOr package) null "The profile picture to use for the user.";
                prompt-init = mkBoolOpt true "Whether or not to show an initial message when opening a new shell.";
                extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
                extraOptions = mkOpt (attrsOf anything) {} "";
            };
        });
    };

    config = {
        users.users = mapAttrs' (n: v: nameValuePair (v.name) ({
            isNormalUser = true;

            inherit (cfg.${v.name}) name initialPassword;

            home = USER_HOME_LOCATION v.name;
            group = "users";

            extraGroups = [ ] ++ cfg.${v.name}.extraGroups;
        } // (cfg.${v.name}.extraOptions))) cfg;
    };
}

#This module will be made available on your flake’s nixosModules,
# darwinModules, or homeModules output with the same name as the directory
# that you created.