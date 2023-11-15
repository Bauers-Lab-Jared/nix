{featureName}: { lib, config, ... }: with lib; 
let
  cfg = config.userFeatures.${featureName};
in
{

  options.userFeatures.${featureName}.enable =
    mkEnableOption "user config for nixvim";

  config.home = mkIf cfg.enable {
    
  };
}