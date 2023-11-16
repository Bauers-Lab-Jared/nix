{ lib, pkgs, config, outputs, ... }: with lib;
let
  inherit (config.thisConfig) otherUsers mainUser features;
  systemUsers = otherUsers ++ [ mainUser ];

  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users = genAttrs systemUsers (userName: {
    openssh.authorizedKeys.keys = [ (builtins.readFile (./userConfig + "/${userName}/ssh.pub")) ];

    isNormalUser = true;
    extraGroups = [ #make this user specific later
      "wheel"
    ] ++ ifTheyExist [
      "video"
      "audio"
      "network"
      "wireshark"
      "git"
    ];
  });

  home-manager.users = genAttrs systemUsers (userName: {    

    imports = [ 
      ( import (./userConfig + "/${userName}") {inherit userName;})
      ./homeFeatures
      ( import ./userConfig {inherit userName;})
      ({ ... }: {
        homeConfig = {
          thisUser = userName;
          features = features ++ [
            #additional features: "feat"
            #Note: these apply to every user's home
          ];
        };
        userConfig = {
          features = features;
        };
      })
    ];

    home = {
      username = userName;
      homeDirectory = mkDefault "/home/${userName}";
      sessionPath = mkDefault [ "$HOME/.local/bin" ];
      sessionVariables = {
        FLAKE = mkDefault "$HOME/NixConfig";
      };
    };
  });
}

