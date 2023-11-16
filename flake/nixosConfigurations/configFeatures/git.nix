{ lib, config, pkgs, ... }: with lib;
{
  config = {
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
    };
  };
}