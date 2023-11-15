{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
  systemName = config.thisConfig.systemName;
in
{
  options.configFeatures.${featureName}.enable =
    mkEnableOption "{WIP} Adds and configures basic network functionality";

  config = mkIf cfg.enable {
    networking.hostName = mkDefault systemName;

    environment.systemPackages = with pkgs; [
      wget
      curl
    ];
  };
}
