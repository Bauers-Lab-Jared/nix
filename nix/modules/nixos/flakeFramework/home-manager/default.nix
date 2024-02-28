{ options, config, pkgs, lib, inputs, ... }:

with lib;
with lib.thisFlake;
let cfg = config.thisFlake.home;
in
{

  options.thisFlake.home = with types; {
    file = mkOpt attrs { }
      (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile = mkOpt attrs { }
      (mdDoc "A set of files to be managed by home-manager's `xdg.configFile`.");
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = {
    thisFlake.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.thisFlake.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.thisFlake.home.configFile;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users = mapAttrs' (n: v: nameValuePair (v.name) ({
        home = {
          username = v.name;
          homeDirectory = "/home/${v.name}";
          sessionPath = mkDefault [ "$HOME/.local/bin" ];
          sessionVariables = {
            FLAKE = mkDefault "$HOME/NixConfig";
          };
        };
      } // mkAliasDefinitions options.thisFlake.home.extraOptions)) config.thisFlake.users;
    };
  };
}