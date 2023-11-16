{ inputs, lib, config, pkgs, ... }: with lib; 
let
  mainUser = config.thisConfig.mainUser;
  systemName = config.thisConfig.systemName;
in
{

  imports = [      
    inputs.nixos-wsl.nixosModules.wsl
  ];

  config = {
    wsl = {
      enable = true;
      defaultUser = mainUser;
    };

    networking.hostName = mkDefault systemName;
    boot.isContainer = true;
    systemd.enableEmergencyMode = false;
  };
}