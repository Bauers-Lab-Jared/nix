{
  lib,
  config,
  ...
}:
with lib;
with lib.thisFlake; let
  locals = {
    inherit config;
    featureType = "system";
    featureName = baseNameOf (toString ./.);
  };
  localLib = mkLocalLib locals;
in
with localLib;
with locals; let

  featureFiles = nixFilesIn ./.;

  featureOptions = featureFiles.${featureName}.options;

  configSets = [
    featureFiles.${feat}.config # will need to break out to list of attrs for each feat
    #forFeat otherFeatureName
    {
      #configuration for other feature paired with this feature
    }
  ];
in {
  #import = {};
  options = mkSystemFeature featureOptions;
  config = mkSystemConfig configSets;
}
