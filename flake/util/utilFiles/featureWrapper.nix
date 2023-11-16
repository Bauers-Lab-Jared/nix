{ lib }: {
  thisUtil = {
    wrapper = {featureName, importDir, setName}: {
      featHandler = args@{ inputs, outputs, lib, config, pkgs, osConfig ? {}, ... }: with lib; 
      let
        cfg = config.${setName}.${featureName};

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
            {${setName}.${featureName}.enable =
              mkEnableOption "";};

        config = mkIf cfg.enable (if (featureImport ? config)
          then featureImport.config
          else {});
      };
    }.featHandler;
  }.wrapper;
}.thisUtil
