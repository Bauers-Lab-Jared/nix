#(https://nixos.wiki/wiki/Module).
{ inputs, outputs, lib, config, pkgs, ... }: with lib;
let
  cfg = config.thisConfig;

  configFeaturesDir = ./.;
  featureFiles = builtins.readDir configFeaturesDir;

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
