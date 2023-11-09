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
  
  users.mutableUsers = false;
  
  security.pam.services = { swaylock = { }; };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
  home-manager.users.${thisConfig.mainUser}.home.stateVersion = lib.mkDefault system.stateVersion;

  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example
    outputs.nixosModules.global

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    
    # You can also split up your configuration and import pieces of it here:
    # Universal System Configuration
    ./features
    (import ./features/wsl { inherit inputs outputs lib config pkgs thisConfig; })

    # Define your users by importing './users/user-name'
    (./users + "/${thisConfig.mainUser}")
    
    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };  
}
