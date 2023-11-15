{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.homeFeatures.${featureName};
in
{
  options.homeFeatures.${featureName}.enable =
    mkEnableOption "{WIP} Adds and configures basic network functionality";

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      wget
      curl
    ];
  };
}
