{ lib, config, pkgs, ... }: with lib;
{

  config = {
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
