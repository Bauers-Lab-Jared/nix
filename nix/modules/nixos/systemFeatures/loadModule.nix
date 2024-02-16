scope:
with scope;
with lib;
with lib.thisFlake; let
  localLib = mkLocalLib scope featModule;
  outScope = scope // featModule // localLib;
  modFile = import featModule.path outScope;
in {
  options = mkFeatureOptions outScope (modFile.options);
  config = modFile.config;
}