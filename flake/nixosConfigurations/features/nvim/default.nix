{ inputs, outputs, pkgs, lib, config, ... }: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
  };
}