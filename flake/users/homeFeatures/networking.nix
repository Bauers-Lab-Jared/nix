{ lib, config, pkgs, ... }: with lib;
{
  config = {
    home.packages = with pkgs; [
      wget
      curl
    ];
  };
}
