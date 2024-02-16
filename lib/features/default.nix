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

  mkLocalLib = moduleArgs: featModule: 
  with moduleArgs;
  with lib;
  with lib.thisFlake; let universal = {
    osConfig = osConfig or config;
    requiredFeats = if featModule ? subFeatName then 
      [featModule.featureName featModule.subFeatName] else
        [featModule.featureName];
    systemHasFeat = targetFeat: osConfig.thisFlake.systemFeatures.${targetFeat}.enable or false;
    systemHasReqFeats = !(elem false (map systemHasFeat requiredFeats));
    combinedFeatName = concatStringsSep "." requiredFeats;
  };
  in
  with universal;
  let
    typeSpecific = if featModule.moduleType == "system" then {
      withModuleAttrPath = attrSet: {thisFlake.systemFeatures.${combinedFeatName} = attrSet;};
      featEnableDefault = false;
      featEnableDesc = "Enables this system feature: ";
    } else if featModule.moduleType == "home" then {
      withModuleAttrPath = attrSet: {thisFlake.homeFeatures.${combinedFeatName} = attrSet;};
      featEnableDefault = systemHasReqFeats;
      featEnableDesc = "Enables this home-manager feature, system-wide: ";
    } else if featModule.moduleType == "user" then {
      withModuleAttrPath = attrSet: {thisFlake.userFeatures.${username}.${combinedFeatName} = attrSet;};
      
      moduleIsForThisUser = username == config.home.username;
      #username comes from the module, config is specific to user

      featEnableDefault = systemHasReqFeats && moduleIsForThisUser;
      featEnableDesc = "Enables this home-manager feature, just for this user: ";
    } else {};
  in
  (universal // typeSpecific);

  mkFeatureOptions = moduleArgs: moduleOptions: 
  with moduleArgs;
  with lib;
  #with lib.thisFlake;
  withModuleAttrPath (recursiveUpdate
      {enable = mkBoolOpt featEnableDefault featEnableDesc;}
      moduleOptions);

  mkFeatures = featureTemplate: moduleType: moduleArgs: featuresRaw: let
    evaluatedAttrs = mapAttrs (outerFeat: outerS: 
      (forEach outerS.featModules (innerFeat: let
        featModule = {
          path = innerFeat.value;
          featureName = outerFeat;
          subFeatName = innerFeat.name;
          inherit moduleType;
        };
        scope = moduleArgs //{inherit featModule;};
      in
      evalModules {modules = [ (import featureTemplate) ]; specialArgs = {inherit scope;}; class = null;}))) featuresRaw;
  in flatten (collect isList evaluatedAttrs);
    

}

