{featureName}: {inputs, lib, config, osConfig, ... }: with lib; 
let
  cfg = config.homeFeatures.${featureName};
in
{
  options.homeFeatures.${featureName}.enable =
    mkEnableOption "Adds and configures home-manager";

  config = mkIf cfg.enable {
    home.stateVersion = mkDefault osConfig.system.stateVersion;
  };
}
