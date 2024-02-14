{lib, ...}: with lib; rec {
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

  systemFeatureLocalLib = {
    config,
    featureName,
    ...
  }: {
    out = {
      osConfig = config;
      hasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
      systemHasFeat = hasFeat;
    };

    _internal = {
      featDefault = false;
      featDescription = "Enables system config feat: ${featureName}";
      appendFeatPath = attrSet: {thisFlake.systemFeatures.${featureName} = attrSet;};
    };
  };

  homeFeatureLocalLib = {
    osConfig,
    featureName,
    ...
  }: {
    out = {
      hasFeat = targetFeat: osConfig.thisFlake.homeFeatures.${targetFeat}.enable or false;
      systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
    };

    _internal = {
      featDefault = systemHasFeat featureName;
      featDescription = "Enables system wide home config feat: ${featureName}";
      appendFeatPath = attrSet: {thisFlake.homeFeatures.${featureName} = attrSet;};
    };
  };

  userFeatureLocalLib = {
    config,
    osConfig,
    username,
    featureName,
    ...
  }: {
    out = {
      hasFeat = targetFeat: osConfig.thisFlake.userFeatures.${username}.${targetFeat}.enable or false;
      systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
      moduleIsForThisUser = username == config.home.username;
      #username comes from the module, config is for user under eval
    };

    _internal = {
      featDefault = (systemHasFeat featureName) && moduleIsForThisUser;
      featDescription = "Enables user specific config feat: ${featureName}";
      appendFeatPath = attrSet: {thisFlake.userFeatures.${username}.${featureName} = attrSet;};
    };
  };

  universalLocalLib = {
    args,
    typeSpecific,
    ...
  }:
    with args;
    with typeSpecific.out;
    with typeSpecific._internal; {
      mkFeature = featureOptions:
        appendFeatPath (recursiveUpdate
          {enable = mkBoolOpt featDefault featDescription;}
          featureOptions);

      forFeat = targetFeat: featConfig: mkIf (hasFeat targetFeat) featConfig;

      mkConfig = configSets: mkIf hasFeat (mkMerge configSets);
    };

  mkLocalLib = args:
    with args; let
      typeSpecific = mkMerge [
        (mkIf (featureType == "system") (systemFeatureLocalLib args))
        (mkIf (featureType == "home") (homeFeatureLocalLib args))
        (mkIf (featureType == "user") (userFeatureLocalLib args))
      ];

      universal = universalLocalLib {inherit args typeSpecific;};
    in
      mkMerge [
        universal.out
        typeSpecific.out
      ];
}

