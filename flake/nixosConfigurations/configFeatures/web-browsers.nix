{ lib, config, pkgs, ... }: with lib;
{
  config = {
    environment.systemPackages = with pkgs; [
      mullvad-browser
    ];
  };
}