{ options, config, pkgs, lib, inputs, ... }:

with lib;
with lib.thisFlake;
let cfg = config.thisFlake.home;
in
{
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];
  
  options.thisFlake.home = with types; {
    file = mkOpt attrs { }
      (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile = mkOpt attrs { }
      (mdDoc "A set of files to be managed by home-manager's `xdg.configFile`.");
    dataFile = mkOpt attrs { }
      (mdDoc "A set of files to be managed by home-manager's `xdg.dataFile`.");
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = {
    thisFlake.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.thisFlake.home.file;
      xdg.enable = true;
      xdg.dataFile = mkAliasDefinitions options.thisFlake.home.dataFile;
      xdg.configFile = mkAliasDefinitions options.thisFlake.home.configFile;
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        music = null;
        pictures = null;
        publicShare = null;
        templates = null;
        videos = null;

      };
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users = mapAttrs' (n: v: nameValuePair (v.name) ({
        home = {
          username = v.name;
          homeDirectory = v.home;
          sessionPath = mkDefault [ "$XDG_BIN_HOME" ];
        };
      } // mkAliasDefinitions options.thisFlake.home.extraOptions)) config.thisFlake.users;
    };
  };
}
