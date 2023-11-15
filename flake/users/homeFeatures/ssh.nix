{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.homeFeatures.${featureName};
in
{

  imports = [      
    
  ];

  options.homeFeatures.${featureName}.enable = 
    mkEnableOption "{WIP} Configures this machine for SSH access";

  config = mkIf cfg.enable {
    
    
  };
  
}