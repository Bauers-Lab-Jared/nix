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

    mkConfigFeature = {config, featureName, otherOptions}: let
        inherit (config.thisFlake.thisConfig) enabledFeatures;
        thisFeatureEnabled = elem featureName enabledFeatures;
    in (recursiveUpdate 
        {thisFlake.configFeatures.${featureName}.enable = 
            mkBoolOpt thisFeatureEnabled "Enables system config feat: ${featureName}";} 
        otherOptions);

    mkHomeFeature = {osConfig, featureName, otherOptions}: let
        inherit (osConfig.thisFlake.thisConfig) enabledFeatures;
        thisFeatureEnabled = elem featureName enabledFeatures;
    in (recursiveUpdate 
        {thisFlake.homeFeatures.${featureName}.enable = 
            mkBoolOpt thisFeatureEnabled "Enables system wide home config feat: ${featureName}";}
        otherOptions);

    mkUserFeature = {config, osConfig, username, featureName, otherOptions}: let
        inherit (osConfig.thisFlake.thisConfig) enabledFeatures;
        thisFeatureEnabled = elem featureName enabledFeatures;
        thisUserHome = (username == config.home.username);
    in (recursiveUpdate 
        {thisFlake.userFeatures.${username}.${featureName}.enable =
            mkBoolOpt (thisFeatureEnabled && thisUserHome) "Enables user specific config feat: ${featureName}";}
        otherOptions);

    hasFeat = {osConfig}: (feat: (elem "nvim" (osConfig.thisFlake.thisConfig.enabledFeatures)));
}