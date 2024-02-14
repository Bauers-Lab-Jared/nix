{
    # This is the merged library containing your namespaced library as well as all libraries from
    # your flake's inputs.
    lib,

    # Your flake inputs are also available.
    inputs,

    # Additionally, Snowfall Lib's own inputs are passed. You probably don't need to use this!
    snowfall-inputs,
}: with lib;
rec {

    mkOpt = type: default: description:
    mkOption { inherit type default description; };

    mkOpt' = type: default: mkOpt type default null;

    mkBoolOpt = mkOpt types.bool;

    mkBoolOpt' = mkOpt' types.bool;

    enabled = {
    enable = true;
    };

    disabled = {
    enable = false;
    };

    systemFeatureLocalLib = {config, featureName, ...}: {
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

    homeFeatureLocalLib = {config, osConfig, featureName, ...}: {
        out = {
            hasFeat = targetFeat: osConfig.thisFlake.homeFeatures.${targetFeat}.enable or false;
            systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
        };

        _internal = {
            featDefault = (systemHasFeat featureName);
            featDescription = "Enables system wide home config feat: ${featureName}";
            appendFeatPath = attrSet: {thisFlake.homeFeatures.${featureName} = attrSet;};
        };
    };

    userFeatureLocalLib = {config, osConfig, username, featureName, ...}: {
        out = {
            hasFeat = targetFeat: osConfig.thisFlake.userFeatures.${username}.${targetFeat}.enable or false;
            systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
            moduleIsForThisUser = (username == config.home.username); 
                #username comes from the module, config is for user under eval
        };
            
        _internal = {
            featDefault = (systemHasFeat featureName) && moduleIsForThisUser;
            featDescription = "Enables user specific config feat: ${featureName}";
            appendFeatPath = attrSet: {thisFlake.userFeatures.${username}.${featureName} = attrSet;};
        };
    };

    universalLocalLib = args: 
    with args;
    with args.out;
    with args._internal; 
    {
        mkFeature = featureOptions: appendFeatPath (recursiveUpdate
            {enable = mkBoolOpt featDefault featDescription;}
            {featureOptions});

        forFeat = targetFeat: featConfig: mkIf (hasFeat targetFeat) featConfig;
        
        mkConfig = configSets: mkIf () (mkMerge configSets);
    };

    mkLocalLib = args@{featureType, ...}: 
    let
        typeSpecific = mkMerge [
            (mkIf (featureType == "system") (systemFeatureLocalLib args))
            (mkIf (featureType == "home") (homeFeatureLocalLib args))
            (mkIf (featureType == "user") (userFeatureLocalLib args))
        ];

        universal = universalLocalLib {{args} // {typeSpecific}};
    in mkMerge [
        universal.out
        typeSpecific.out
    ];
    

    
}