#(https://nixos.wiki/wiki/Module).
{ userName }: { inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  inherit (inputs) util;
  cfg = config.userConfig;

  userFeaturesDir = (./. + "/${userName}/userFeatures");
  featureNames = util.nixNamesInDir userFeaturesDir;
  setName = "userFeatures";
  
  hasFeat = (featName: (builtins.elem featName cfg.features));
in
{
  imports = builtins.map (featureName: 
    (util.featureWrapper { inherit featureName setName; importDir = userFeaturesDir;})
  ) featureNames;
  
  options.userConfig = {
    enable = mkOption {
      description = "Enable this users custom settings";
      type = types.bool;
      default = true;
    };

    availableUserFeatures = mkOption {
      description = "List of features for which home has generic config";
      type = types.listOf types.str;
      default = featureNames;
    };

    features = mkOption {
      description = "Features to enable";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    userFeatures = genAttrs featureNames
      (feat: {enable = mkIf (hasFeat feat) true;});
  };
}
