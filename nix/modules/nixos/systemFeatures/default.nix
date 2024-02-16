moduleArgs:
with moduleArgs;
with lib;
with lib.thisFlake;
let
  featuresRaw = getFeatModules ./features;
  #featSetsRaw = getFeatModules ./featSets;
  #systemDefsRaw = getFeatModules ./systemDefs;
in
{

  imports = let
    systemFeatures = mkFeatures ./loadModule.nix "system" moduleArgs featuresRaw;
    #systemFeatSets = mkFeatures "system" moduleArgs featSetsRaw;
    #systemDefs = mkFeatures "system" moduleArgs systemDefsRaw;
  in traceVal systemFeatures;# ++ systemFeatSets ++ systemDefs;



}