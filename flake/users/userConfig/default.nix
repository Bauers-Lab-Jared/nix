#(https://nixos.wiki/wiki/Module).
{ userName }: { inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  cfg = config.userConfig;
  userFeaturesDir = (./. + "/${userName}/userFeatures");
  featureFiles = builtins.readDir userFeaturesDir;

  featureNames = if (featureFiles == {}) then [] else
    builtins.filter (x: x != "default")
      (foldlAttrs 
        (acc: key: value: 
          if value == "regular" 
          then acc ++ [
            (builtins.replaceStrings [".nix"] [""] key)] 
          else acc ) 
        [] 
        (featureFiles)
      );

  hasFeat = (featName: (builtins.elem featName cfg.features));
in
{
  imports = builtins.map (featureName: 
    (import (userFeaturesDir + "/${featureName}.nix") { inherit featureName; })
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
