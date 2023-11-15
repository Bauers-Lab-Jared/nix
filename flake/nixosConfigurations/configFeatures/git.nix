{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{
  options.configFeatures.${featureName}.enable =
    mkEnableOption "installs full git";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
    };
  };
}