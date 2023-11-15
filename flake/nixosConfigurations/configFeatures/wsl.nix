{featureName}: { inputs, lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
  mainUser = config.thisConfig.mainUser;
  systemName = config.thisConfig.systemName;
in
{

  imports = [      
    inputs.nixos-wsl.nixosModules.wsl
  ];

  options.configFeatures.${featureName}.enable =
    mkEnableOption "Windows Subsystem for Linux";

  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = mainUser;
    };

    networking.hostName = systemName;
    boot.isContainer = true;
    systemd.enableEmergencyMode = false;
  };
}