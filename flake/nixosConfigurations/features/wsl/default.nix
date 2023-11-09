{inputs, outputs, lib, config, pkgs, thisConfig, ... }: {
    imports = [      
      inputs.nixos-wsl.nixosModules.wsl
    ];

  wsl.enable = true;
  wsl.defaultUser = thisConfig.mainUser;
}