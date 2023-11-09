{inputs, outputs, lib, config, pkgs, thisConfig, ... }: {
    imports = [      
      inputs.nixos-wsl.nixosModules.wsl
    ];

  wsl.enable = true;
  
  # Required settings per system:
  # wsl.defaultUser = username;
  
}