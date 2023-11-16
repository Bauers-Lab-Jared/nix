{inputs, lib, config, osConfig, ... }: with lib;
{
  config = {
    home.stateVersion = mkDefault osConfig.system.stateVersion;
  };
}
