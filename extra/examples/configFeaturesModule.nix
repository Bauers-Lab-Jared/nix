# This is an example starting point for creating a configuration module
#   to be compatible with this flake's organization.

#Usage:
# ConfigFeature modules will automatically be picked up by the flake,
#   if they are added to /flake/nixosConfigurations/configFeatures/${featureName}.nix

#NOTE: The name of this file will be the name of the module in config.configFeatures
{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{

  imports = [      
    # EX: inputs.home-manager.nixosModules.home-manager
  ];

  options.configFeatures.${featureName}.enable = mkEnableOption "short desc";

  config = mkIf cfg.enable {
    
    #Place the usual config here.
    
  };
  
}