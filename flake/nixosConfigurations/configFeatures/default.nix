#(https://nixos.wiki/wiki/Module).
{ inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  inherit (inputs) util;
  cfg = config.thisConfig;

  configFeaturesDir = ./.;
  featureNames = util.nixNamesInDir configFeaturesDir;
  setName = "configFeatures";

  hasFeat = (featName: (builtins.elem featName cfg.features));
in
{
  imports = builtins.map (featureName: 
    (util.featureWrapper { inherit featureName setName; importDir = configFeaturesDir; })
  ) featureNames;
  
  options.thisConfig = {
    enable = mkOption {
      description = "Enable thisConfig to store values for eval of this config";
      type = types.bool;
      default = true;
    };

    systemName = mkOption {
      type = types.str;
      default = "nixos";
    };

    availableFeatures = mkOption {
      description = "List of known features";
      type = types.listOf types.str;
      default = featureNames;
    };

    features = mkOption {
      description = "Features to enable";
      type = types.listOf types.str;
      default = [];
    };

    mainUser = mkOption {
      description = "The main user for the system";
      type = types.str;
      default = "nixos";
    };

    otherUsers = mkOption {
      description = "additional users to allow on the system";
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    configFeatures = genAttrs featureNames
      (feat: {enable = mkIf (hasFeat feat) true;});
  };
}
