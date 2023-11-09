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
  
  time.timeZone = lib.mkDefault "US/Eastern";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
  home-manager.users.${thisConfig.mainUser}.home.stateVersion = lib.mkDefault system.stateVersion;
  
  wsl.defaultUser = thisConfig.mainUser;

  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    
    # You can also split up your configuration and import pieces of it here:
    # Universal System Configuration
    ./features
    ./features/wsl

    # Define your users by importing './users/user-name'
    (../users + "/${thisConfig.mainUser}")
    
    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };  
}
