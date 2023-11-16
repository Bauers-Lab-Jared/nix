{ inputs, outputs, lib, config, pkgs, ... }: with lib;
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit inputs outputs; };
    };
    
  };
}
