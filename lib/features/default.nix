{lib, ...}:
with lib;
with builtins; rec {
#defines
  WITH_SYSTEM_FEAT_PATH = attrSet: {thisFlake.systemFeatures = attrSet;};
  WITH_HOME_FEAT_PATH = attrSet: {thisFlake.homeFeatures = attrSet;};
  WITH_USER_FEAT_PATH = username: attrSet: {thisFlake.userFeatures.${username} = attrSet;};
  FROM_SYSTEM_FEAT_PATH = osConfig: osConfig.thisFlake.systemFeatures;
  FROM_HOME_FEAT_PATH = config: config.thisFlake.homeFeatures;
  FROM_USER_FEAT_PATH = username: config: config.thisFlake.userFeatures.${username};

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
      then osConfig else config;

    username = if info ? username
      then info.username else null;

    withFeatNamesFrom = attrSet:
      if info ? subFeatName
      then attrSet.${info.featTier}.${info.featureName}.${info.subFeatName}
      else attrSet.${info.featTier}.${info.featureName};
  in rec {
    featConf = {
      system = FROM_SYSTEM_FEAT_PATH osC;
      home = FROM_HOME_FEAT_PATH config;
      user = mkIf (username != null) (FROM_USER_FEAT_PATH username config);
    };

    cfg = withFeatNamesFrom featConf.${info.moduleType};

    hasFeat = featType: featTier: targetFeat: featConf.${featType}.${featTier}.${targetFeat}.enable or false;
    cfgHasFeat = hasFeat info.moduleType;
    systemHasFeat = hasFeat "system";

    systemHasReqFeats = 
      (systemHasFeat info.featTier info.featureName)
      && ( if info ? subFeatName
        then systemHasFeat info.featTier info.subFeatName
        else true);

    thisFeatEnabled =
      if (info ? featureName)
      then (cfgHasFeat info.featTier info.featureName)
      else
        false
        && (
          if info ? subFeatName
          then cfgHasFeat info.featTier info.subFeatName
          else true
        );
  };
  #####
  mkFeatPath = args: info: with args; let
    username = if info ? username
      then info.username else null;

    withFeatNames = attrSet:
      if info ? subFeatName
      then {${info.featTier}.${info.featureName}.${info.subFeatName} = attrSet;}
      else {${info.featTier}.${info.featureName} = attrSet;};

    out = {
      system = attrSet: WITH_SYSTEM_FEAT_PATH (withFeatNames attrSet);
      home = attrSet: WITH_HOME_FEAT_PATH (withFeatNames attrSet);
      user = attrSet: WITH_USER_FEAT_PATH username (withFeatNames attrSet);
    };
  in 
  out.${info.moduleType};
  #####
  mkLocalLib = {
    moduleArgs,
    moduleFilePath,
  }:
  with moduleArgs;
  with moduleArgs.lib;
  with moduleArgs.lib.thisFlake;
  let 
    moduleInfo = moduleInfoFromPath moduleFilePath;
    featRefs = mkFeatRefs moduleArgs moduleInfo;
  in
  with featRefs;
  let 
  universal = rec {
    inherit moduleInfo;
    withFeatPath = mkFeatPath moduleArgs moduleInfo;
  } // featRefs;
  in
  with universal;
  let
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
        featEnableDesc = "Enables this home-manager feature, just for ${moduleInfo.username}: ${featNames}";
      }
      else {};
  in
    universal // typeSpecific;
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

      options = withFeatPath (recursiveUpdate
        {enable = mkBoolOpt featEnableDefault featEnableDesc;}
        featOptions);

      config = mkIf thisFeatEnabled featConfig;
    };
}
