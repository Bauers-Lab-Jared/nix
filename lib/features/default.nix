{
    # This is the merged library containing your namespaced library as well as all libraries from
    # your flake's inputs.
    lib,

    # Your flake inputs are also available.
    inputs,

    # Additionally, Snowfall Lib's own inputs are passed. You probably don't need to use this!
    snowfall-inputs,
}: with lib; 
let
    mkOpt = type: default: description:
        mkOption { inherit type default description; };

    mkOpt' = type: default: mkOpt type default null;

    mkBoolOpt = mkOpt types.bool;
in rec {

    mkConfigFeature = {config, featureName, otherOptions}: (recursiveUpdate 
        {thisFlake.configFeatures.${featureName}.enable = 
            mkBoolOpt false "Enables system config feat: ${featureName}";} 
        otherOptions);

    mkHomeFeature = {osConfig, featureName, otherOptions}: let
        thisFeatureEnabled = osConfig.thisFlake.configFeatures.${featureName}.enable;
    in (recursiveUpdate 
        {thisFlake.homeFeatures.${featureName}.enable = 
            mkBoolOpt thisFeatureEnabled "Enables system wide home config feat: ${featureName}";}
        otherOptions);

    mkUserFeature = {config, osConfig, username, featureName, otherOptions}: let
        thisFeatureEnabled = osConfig.thisFlake.configFeatures.${featureName}.enable;
        thisUserHome = (username == config.home.username);
    in (recursiveUpdate 
        {thisFlake.userFeatures.${username}.${featureName}.enable =
            mkBoolOpt (thisFeatureEnabled && thisUserHome) "Enables user specific config feat: ${featureName}";}
        otherOptions);

    hasFeat = {osConfig}: (feat: (elem feat (builtins.attrNames osConfig.thisFlake.configFeatures)));
}