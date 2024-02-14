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
  featureOptions = with types; {
  };

  configSets = [
    {
      #configuration for this feature
    }
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
