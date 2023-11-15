#(https://nixos.wiki/wiki/Module).
{ inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  cfg = config.homeConfig;

  homeFeaturesDir = ./.;
  featureFiles = builtins.readDir homeFeaturesDir;

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
    (import (./. + "/${featureName}.nix") { inherit featureName; })
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
