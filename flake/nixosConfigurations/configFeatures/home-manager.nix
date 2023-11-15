{featureName}: { inputs, outputs, lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.configFeatures.${featureName}.enable =
    mkEnableOption "Adds and configures home-manager";

  config = mkIf cfg.enable {

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit inputs outputs; };
    };
    
  };
}
