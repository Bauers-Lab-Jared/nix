{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: { 
  imports = [
    ./features
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  }; 
}