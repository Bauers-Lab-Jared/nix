{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{
  options.configFeatures.${featureName}.enable =
    mkEnableOption "Adds and sets default shell to fish";

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };

    # Set default shell to fish global
    users.defaultUserShell = pkgs.fish;
  };
}
