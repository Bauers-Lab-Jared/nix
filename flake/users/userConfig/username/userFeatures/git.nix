{featureName}: { lib, config, ... }: with lib; 
let
  cfg = config.userFeatures.${featureName};
in
{
  options.userFeatures.${featureName}.enable =
    mkEnableOption "custom config for git";

  config = mkIf cfg.enable {
    programs.git = {
      userName = "Jared";
      userEmail = "127258074+Bauers-Lab-Jared@users.noreply.github.com";
    };
  };
}
