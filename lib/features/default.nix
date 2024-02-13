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

    mkSystemFeature = {config, featureName, otherOptions}: (recursiveUpdate 
        {thisFlake.systemFeatures.${featureName}.enable = 
            mkBoolOpt false "Enables system config feat: ${featureName}";} 
        {thisFlake.systemFeatures.${featureName} = otherOptions});

    mkHomeFeature = {osConfig, featureName, otherOptions}: let
        thisFeatureEnabled = osConfig.thisFlake.systemFeatures.${featureName}.enable;
    in (recursiveUpdate 
        {thisFlake.homeFeatures.${featureName}.enable = 
            mkBoolOpt thisFeatureEnabled "Enables system wide home config feat: ${featureName}";}
        {thisFlake.homeFeatures.${featureName} = otherOptions});

    mkUserFeature = {config, osConfig, username, featureName, otherOptions}: let
        thisFeatureEnabled = osConfig.thisFlake.systemFeatures.${featureName}.enable;
        thisUserHome = (username == config.home.username);
    in (recursiveUpdate 
        {thisFlake.userFeatures.${username}.${featureName}.enable =
            mkBoolOpt (thisFeatureEnabled && thisUserHome) "Enables user specific config feat: ${featureName}";}
        {thisFlake.userFeatures.${username}.${featureName} = otherOptions});

    hasFeat = {osConfig}: (feat: (elem feat (builtins.attrNames osConfig.thisFlake.systemFeatures)));
}