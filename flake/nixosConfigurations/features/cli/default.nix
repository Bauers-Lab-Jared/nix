{ inputs, outputs, pkgs, lib, config, ... }: {
  imports = [
    ./fish.nix
    ./nvim.nix
  ];

  # Add dconf settings
  programs.dconf.enable = true;
}