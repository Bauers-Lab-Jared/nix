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

  enableFeatList = featList: genAttrs featList (n: enabled);
  disableFeatList = featList: genAttrs featList (n: disabled);

  #####
  matchFeatPath = match ".*\/([^\/]+)\/([^\/]+)Features\/(features|featSets|systemDefs)\/([^\/]+\/)*([^\/]+)\/([^\/]+).nix$";
  #####
  moduleInfoFromPath = path: let
    matchedList = matchFeatPath path;
    lst = n: if matchedList != null then elemAt matchedList n
      else null;
    username = lst 0;
    moduleType = lst 1;
    featTier = lst 2;
    featureName = lst 4;
    subFeatName = lst 5;

    outAttrs = {inherit moduleType featTier featureName path;}
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
  in if any (x: x == null) (attrValues outAttrs) then null
    else outAttrs;
    
  #####
  moduleInfoFromPathList = pathList: let
    raw = map (x: moduleInfoFromPath x) pathList;
  in filter (y: y != null) raw;
  #####
  modulePathsFromDir = dir: let
    rawPaths = filesystem.listFilesRecursive dir;
  in
    filter (x: !(hasSuffix "default.nix" x) && !(hasSuffix "example.nix" x) && (hasSuffix ".nix" x)) (map toString rawPaths);
  #####
  mkFeatRefs = args: info: with args; let
    osC = if args ? osConfig
      then config else osConfig;

    username = if info ? username
      then info.username else null;
    
  in {
    system = osC.thisFlake.systemFeatures;
    home = config.thisFlake.homeFeatures;
    user = mkIf (username != null) config.thisFlake.userFeatures.${username};
  };
  #####
  mkFeatPaths = args: info: with args; let
    username = if info ? username
      then info.username else null;    
  in {
    system = attrSet: {thisFlake.systemFeatures = attrSet;};
    home = attrSet: {thisFlake.homeFeatures = attrSet;};
    user = mkIf (username != null) (attrSet: {thisFlake.userFeatures.${username} = attrSet;});
  };
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
        featConf = mkFeatRefs moduleArgs moduleInfo;
        withFeatPath = mkFeatPaths moduleArgs moduleInfo;
        systemHasFeat = featTier: targetFeat: featConf.sys.${featTier}.${targetFeat}.enable or false;
        systemHasReqFeats = 
          (systemHasFeat moduleInfo.featTier moduleInfo.featureName)
          && ( if moduleInfo ? subFeatName
            then systemHasFeat moduleInfo.featTier moduleInfo.subFeatName
            else true);
      };
    in
      with universal; let
        withFeatNames = attrSet:
          if moduleInfo ? subFeatName
          then {${moduleInfo.featTier}.${moduleInfo.featureName}.${moduleInfo.subFeatName} = attrSet;}
          else {${moduleInfo.featTier}.${moduleInfo.featureName} = attrSet;};
        withFeatNamesFrom = attrSet:
          if moduleInfo ? subFeatName
          then attrSet.${moduleInfo.featTier}.${moduleInfo.featureName}.${moduleInfo.subFeatName}
          else attrSet.${moduleInfo.featTier}.${moduleInfo.featureName};
        featNames = 
          if moduleInfo ? subFeatName
          then "${moduleInfo.featTier}.${moduleInfo.featureName}.${moduleInfo.subFeatName}"
          else "${moduleInfo.featTier}.${moduleInfo.featureName}";
        typeSpecific =
          if moduleInfo.moduleType == "system"
          then {
            featEnableDefault = false;
            featEnableDesc = "Enables this system feature: ${featNames}";
          }
          else if moduleInfo.moduleType == "home"
          then {
            featEnableDefault = systemHasReqFeats;
            featEnableDesc = "Enables this home-manager feature, system-wide: ${featNames}";
          }
          else if moduleInfo.moduleType == "user"
          then rec {
            moduleIsForThisUser = moduleInfo.username == config.home.username;
            #username comes from the module, config is specific to user

            featEnableDefault = systemHasReqFeats && moduleIsForThisUser;
            featEnableDesc = "Enables this home-manager feature, just for this user: ${featNames}";
          }
          else {};
      in
        with typeSpecific; let
          featConfPath = featConf.${moduleInfo.moduleType};
          universalExt =
            universal
            // rec {
              withModuleAttrPath = attrSet: withFeatPath.${moduleInfo.moduleType} withFeatNames attrSet;
              cfg = withFeatNamesFrom featConfPath;
              cfgHasFeat = featTier: targetFeat: featConfPath.${featTier}.${targetFeat}.enable or false;

              thisFeatEnabled =
                if (moduleInfo ? featureName)
                then (cfgHasFeat moduleInfo.featTier moduleInfo.featureName)
                else
                  false
                  && (
                    if moduleInfo ? subFeatName
                    then cfgHasFeat moduleInfo.featTier moduleInfo.subFeatName
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
  mkFeatureFile = {
    scope,
    featOptions,
    featConfig,
    imports,
  }:
    with scope; {
      inherit imports;

      options = withModuleAttrPath (recursiveUpdate
        {enable = mkBoolOpt featEnableDefault featEnableDesc;}
        featOptions);

      config = mkIf thisFeatEnabled featConfig;
    };
}
