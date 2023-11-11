{inputs, outputs, lib, config, pkgs, thisConfig, ... }: {
    imports = [      
      inputs.nixos-wsl.nixosModules.wsl
    ];

  wsl.enable = true;
  
  boot.isContainer = true;

  systemd.enableEmergencyMode = false;
  
  # Required settings per system:
  # wsl.defaultUser = username;
  
}