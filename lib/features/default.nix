{lib, ...}: with lib; 
with builtins; rec {
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkBoolOpt' = mkOpt' types.bool;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

##### current
  matchFeatPath = match ".*\/(.*)Features\/features\/([^\/]+\/)*([^\/]+)\/([^\/]+).nix$";
#####
  moduleInfoFromPath = path: let
      matchedList = matchFeatPath path;
      lst = n: elemAt matchedList n;
      moduleType = lst 0;
      username = lst 1;
      featureName = lst 2;
      subFeatName = lst 3;
  in {inherit moduleType featureName path;} 
      // (if (featureName != subFeatName) then {inherit subFeatName;} else {})
      // (if (moduleType == "user") then {inherit username;} else {});
#####
  moduleInfoFromPathList = pathList: map (path: moduleInfoFromPath path) pathList;
#####
  modulePathsFromDir = dir: let
      rawPaths = filesystem.listFilesRecursive dir;
  in filter (x: !(hasSuffix "default.nix" x) && (hasSuffix ".nix" x)) (map toString rawPaths);
#####
  mkLocalLib = {moduleArgs, moduleFilePath}:
  with moduleArgs;
  with lib;
  with lib.thisFlake; 
  let 
    universal = rec {
      moduleInfo = moduleInfoFromPath moduleFilePath;
      osConfig = osConfig or config;
      systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
      systemHasReqFeats = (systemHasFeat moduleInfo.featureName) && 
        (if moduleInfo ? subFeatName then systemHasFeat moduleInfo.subFeatName else true);
    };
    withFeatNames = attrSet: if moduleInfo ? subFeatName then
      {${moduleInfo.featureName} = attrSet;}
    else {${moduleInfo.featureName}.${moduleInfo.subFeatName} = attrSet;};
    fromFeatNames = attrSet: if moduleInfo ? subFeatName then
      attrSet.${moduleInfo.featureName}
    else attrSet.${moduleInfo.featureName}.${moduleInfo.subFeatName};
  in
  with universal;
  let
    typeSpecific = if moduleInfo.moduleType == "system" then {
      featEnableDefault = false;
      featEnableDesc = "Enables this system feature: ";
      withModuleAttrPath = attrSet: withFeatNames {thisFlake.systemFeatures = attrSet;};
      fromModuleAttrPath = fromFeatNames config.thisFlake.systemFeatures;
      cfgHasFeat = systemHasFeat;
    } else if moduleInfo.moduleType == "home" then {
      featEnableDefault = systemHasReqFeats;
      featEnableDesc = "Enables this home-manager feature, system-wide: ";
      withModuleAttrPath = attrSet: withFeatNames {thisFlake.homeFeatures = attrSet;};
      fromModuleAttrPath = fromFeatNames config.thisFlake.homeFeatures;
      cfgHasFeat = targetFeat: config.thisFlake.homeFeatures.${targetFeat}.enable or false;
    } else if moduleInfo.moduleType == "user" then rec {
      
      moduleIsForThisUser = moduleInfo.username == config.home.username;
      #username comes from the module, config is specific to user

      featEnableDefault = systemHasReqFeats && moduleIsForThisUser;
      featEnableDesc = "Enables this home-manager feature, just for this user: ";
      withModuleAttrPath = attrSet: withFeatNames {thisFlake.userFeatures.${moduleInfo.username} = attrSet;};
      fromModuleAttrPath = fromFeatNames config.thisFlake.userFeatures.${moduleInfo.username};
      cfgHasFeat = targetFeat: config.thisFlake.userFeatures.${moduleInfo.username}.${targetFeat}.enable or false;
    } else {};
  in
  with typeSpecific;
  let
    universalExt = universal // {
      thisFeatEnabled = (cfgHasFeat moduleInfo.featureName) && 
        (if moduleInfo ? subFeatName then cfgHasFeat moduleInfo.subFeatName else true);
    };
  in
  (universalExt // typeSpecific);
#####
  mkFeatureScope = {moduleArgs, moduleFilePath}: let
    localLib = lib.thisFlake.mkLocalLib {inherit moduleArgs moduleFilePath;};
  in moduleArgs // lib // lib.thisFlake // localLib;
#####
  mkFeatureFile = {scope, options, config}:
  with scope;
  {
    options = withModuleAttrPath (recursiveUpdate 
      {enable = mkBoolOpt featEnableDefault featEnableDesc;}
      options);

    config = mkIf thisFeatEnabled config;
  };
}

