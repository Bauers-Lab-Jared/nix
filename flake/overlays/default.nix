# This file defines overlays
{inputs, ...}: let
  additions = final: _prev: import ../customPkgs {pkgs = final;};
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
in
  inputs.nixpkgs.lib.composeManyExtensions [additions modifications]
