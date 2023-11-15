{ inputs, lib, config, pkgs, ... }: with lib; 
{

  imports = [      
    inputs.nixvim.nixosModules.nixvim
  ];

  config = {
    programs.nixvim = {
      enable = true;
    };
  };
}