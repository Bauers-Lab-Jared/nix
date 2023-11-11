# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  thisConfig.mainUser = "waffle";
in
rec {
  system.name = "wslwaffle";
  networking.hostName = "${system.name}";
  nixpkgs.hostPlatform = "x86_64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
  home-manager.users.${thisConfig.mainUser}.home.stateVersion = lib.mkDefault system.stateVersion;
  
  wsl.defaultUser = thisConfig.mainUser;

  imports = [
    ./features/wsl
    ./features/cli
    ./features/nvim
    ./features/xserver

    # Define your users by importing './users/user-name'
    (../users + "/${thisConfig.mainUser}")
  ];

  environment.systemPackages = with pkgs; [
    mullvad-browser
  ];

}
