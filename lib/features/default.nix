{lib, ...}:
with lib;
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
  matchFeatPath = match ".*\/([^\/]+)Features\/(features|featSets|systemDefs)\/([^\/]+\/)*([^\/]+)\/([^\/]+).nix$";
  #####
  moduleInfoFromPath = path: let
    matchedList = matchFeatPath path;
    lst = n: elemAt matchedList n;
    moduleType = lst 0;
    featTier = lst 1;
    username = lst 2;
    featureName = lst 3;
    subFeatName = lst 4;
  in
    {inherit moduleType featTier featureName path;}
    // (
      if (featureName != subFeatName)
      then {inherit subFeatName;}
      else {}
    )
    // (
      if (moduleType == "user")
      then {inherit username;}
      else {}
    );
  #####
  moduleInfoFromPathList = pathList: map (x: moduleInfoFromPath x) pathList;
  #####
  modulePathsFromDir = dir: let
    rawPaths = filesystem.listFilesRecursive dir;
  in
    filter (x: !(hasSuffix "default.nix" x) && (hasSuffix ".nix" x)) (map toString rawPaths);
  #####
  mkLocalLib = {
    moduleArgs,
    moduleFilePath,
  }:
    with moduleArgs;
    with moduleArgs.lib;
    with moduleArgs.lib.thisFlake; let
      universal = rec {
        moduleInfo = moduleInfoFromPath moduleFilePath;
        osConfig = osConfig or config;
        systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
        systemHasReqFeats =
          (systemHasFeat moduleInfo.featureName)
          && (
            if moduleInfo ? subFeatName
            then systemHasFeat moduleInfo.subFeatName
            else true
          );
      };
      in
      with universal;
      let
        withFeatNames = attrSet:
          if moduleInfo ? subFeatName
          then {${moduleInfo.featureName}.${moduleInfo.subFeatName} = attrSet;}
          else {${moduleInfo.featureName} = attrSet;};
        fromFeatNames = attrSet:
          if moduleInfo ? subFeatName
          then attrSet.${moduleInfo.featureName}.${moduleInfo.subFeatName}
          else attrSet.${moduleInfo.featureName};
        typeSpecific =
          if moduleInfo.moduleType == "system"
          then {
            featEnableDefault = false;
            featEnableDesc = "Enables this system feature: ";
            withModuleAttrPath = attrSet: {thisFlake.systemFeatures = withFeatNames attrSet;};
            fromModuleAttrPathBase = config.thisFlake.systemFeatures;
          }
          else if moduleInfo.moduleType == "home"
          then {
            featEnableDefault = systemHasReqFeats;
            featEnableDesc = "Enables this home-manager feature, system-wide: ";
            withModuleAttrPath = attrSet: {thisFlake.homeFeatures = withFeatNames attrSet;};
            fromModuleAttrPathBase = config.thisFlake.homeFeatures;
          }
          else if moduleInfo.moduleType == "user"
          then rec {
            moduleIsForThisUser = moduleInfo.username == config.home.username;
            #username comes from the module, config is specific to user

            featEnableDefault = systemHasReqFeats && moduleIsForThisUser;
            featEnableDesc = "Enables this home-manager feature, just for this user: ";
            withModuleAttrPath = attrSet: {thisFlake.userFeatures.${moduleInfo.username} = withFeatNames attrSet;};
            cfg = config.thisFlake.userFeatures.${moduleInfo.username};
          }
          else {};
      in
        with typeSpecific; let
          universalExt =
            universal
            // rec {
              cfg = fromFeatNames fromModuleAttrPathBase;
              cfgHasFeat = targetFeat: (fromModuleAttrPathBase).${targetFeat}.enable or false;
              thisFeatEnabled =
                (cfgHasFeat moduleInfo.featureName)
                && (
                  if moduleInfo ? subFeatName
                  then cfgHasFeat moduleInfo.subFeatName
                  else true
                );
            };
        in
          universalExt // typeSpecific;
  #####
  mkFeatureScope = {
    moduleArgs,
    moduleFilePath,
  }: let
    localLib = moduleArgs.lib.thisFlake.mkLocalLib {inherit moduleArgs moduleFilePath;};
  in
    moduleArgs // moduleArgs.lib // moduleArgs.lib.thisFlake // localLib;
  #####
  mkFeatureFile = {scope, featOptions, featConfig, imports}: with scope;
  {
    inherit imports;
    
    options = withModuleAttrPath (recursiveUpdate
      {enable = mkBoolOpt featEnableDefault featEnableDesc;}
      featOptions);
      
    config = mkIf thisFeatEnabled featConfig;
  };
}
