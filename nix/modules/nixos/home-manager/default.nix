{ options, config, pkgs, lib, inputs, ... }:

with lib;
with lib.thisFlake;
let cfg = config.thisFlake.home;
in
{

  config = {

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users = mapAttrs' (n: v: nameValuePair (v.name) ({
        home = {
          username = v.name;
          homeDirectory = "/home/${v.name}";
          stateVersion = config.system.stateVersion;
          sessionPath = mkDefault [ "$HOME/.local/bin" ];
          sessionVariables = {
            FLAKE = mkDefault "$HOME/NixConfig";
          };
        };
      })) config.thisFlake.users;
    };
  };
}