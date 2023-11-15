#(https://nixos.wiki/wiki/Module).
{ inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  inherit (inputs) util;
  cfg = config.homeConfig;

  homeFeaturesDir = ./.;
  featureNames = util.nixNamesInDir homeFeaturesDir;
  setName = "homeFeatures";

  hasFeat = (featName: (builtins.elem featName cfg.features));
in
{
  imports = builtins.map (featureName: 
    (util.featureWrapper { inherit featureName setName; importDir = homeFeaturesDir;})
  ) featureNames;
  
  options.homeConfig = {
    enable = mkOption {
      description = "Enable thisHomeConfig to store values for eval of this user under home-manager";
      type = types.bool;
      default = true;
    };

    availableHomeFeatures = mkOption {
      description = "List of features for which home has generic config";
      type = types.listOf types.str;
      default = featureNames;
    };

    features = mkOption {
      description = "Features to enable";
      type = types.listOf types.str;
    };

    thisUser = mkOption {
      description = "The user associated with this homeConfig";
      type = types.listOf types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    homeFeatures = genAttrs featureNames
      (feat: {enable = mkIf (hasFeat feat) true;});
  };
}
