{ config, osConfig, pkgs, lib, inputs, ... }: {
  
  imports = (if (osConfig.programs ? nixvim && osConfig.programs.nixvim.enable) then [
    inputs.nixvim.homeManagerModules.nixvim
    ./options.nix
    ./plugins
    ./colorscheme.nix
  ] else []);
}