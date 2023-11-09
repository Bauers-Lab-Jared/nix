{ config, pkgs, lib, ... }: {
  
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;

      flavour = "mocha";
      terminalColors = true; 
      background.dark = "mocha";
      dimInactive.enabled = true;
    };
  };
}