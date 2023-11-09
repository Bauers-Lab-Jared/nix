{ lib, pkgs, config, ... }: 
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
  };
}
