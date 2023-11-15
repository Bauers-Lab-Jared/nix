{featureName}: { inputs, lib, config, pkgs, ... }: with lib; 
let
  cfg = config.configFeatures.${featureName};
in
{

  imports = [      
    inputs.nixvim.nixosModules.nixvim
  ];

  options.configFeatures.${featureName}.enable =
    mkEnableOption "nixvim: neovim packaged for nix";

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
    };
  };
}