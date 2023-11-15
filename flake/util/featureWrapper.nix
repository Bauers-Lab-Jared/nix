{ lib }: {
  thisUtil = {
    wrapper = {featureName, importDir}: {
      featHandler = args@{ inputs, outputs, lib, config, pkgs, ... }: with lib; 
      let
        cfg = config.configFeatures.${featureName};

        featureImport = import (importDir + "/${featureName}.nix") (args);
      in
      {
        imports = 
          if (featureImport ? imports)
          then featureImport.imports 
          else [];

        options = (if (featureImport ? options) 
          then featureImport.options
          else {}) // 
            {configFeatures.${featureName}.enable =
              mkEnableOption "";};

        config = mkIf cfg.enable (if (featureImport ? config)
          then featureImport.config
          else {});
      };
    }.featHandler;
  }.wrapper;
}.thisUtil
