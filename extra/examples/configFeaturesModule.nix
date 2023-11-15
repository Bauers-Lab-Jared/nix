# This is an example starting point for creating a configuration module
#   to be compatible with this flake's organization.

#Usage:
# ConfigFeature modules will automatically be picked up by the flake,
#   if they are added to /flake/nixosConfigurations/configFeatures/${featureName}.nix

#NOTE: The name of this file will be the name of the module in config.configFeatures
{ lib, config, pkgs, ... }: with lib;
{

  imports = [
    # EX: inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    
    #Place the usual config here.
    
  };
  
}