{ lib, config, pkgs, ... }: with lib; 
let
  systemName = config.thisConfig.systemName;
in
{
  config = {
    networking.hostName = mkDefault systemName;

    environment.systemPackages = with pkgs; [
      wget
      curl
    ];
  };
}
