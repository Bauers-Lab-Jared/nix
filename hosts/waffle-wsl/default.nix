{ lib, pkgs, config, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl

    ../common/global
    ../common/users/waffle

    #../common/optional/pipewire.nix
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  networking = {
    hostName = "waffle-wsl";
    useDHCP = true;
  };

  programs = {
    dconf.enable = true;
    #kdeconnect.enable = true;
  };

  #xdg.portal = {
  #  enable = true;
  #  wlr.enable = true;
  #};

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05";
}
