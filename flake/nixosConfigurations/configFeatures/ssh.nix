{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{

  imports = [      
    
  ];

  options.configFeatures.${featureName}.enable = 
    mkEnableOption "{WIP} Configures this machine for SSH access";

  config = mkIf cfg.enable {
    
    
  };
  
}