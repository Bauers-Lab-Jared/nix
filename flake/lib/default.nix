#(https://nixos.wiki/wiki/Module).
#super broken
args@{inputs, outputs, ... }: with builtins;
let
  inherit (inputs) nixpkgs home-manager;
  library = nixpkgs.lib // home-manager.lib;

  listNixNames = dir:
    filter (x: x != "default")
    (library.foldlAttrs 
      (acc: key: value: 
        if value == "regular" 
        then acc ++ [
          (replaceStrings [".nix"] [""] key)] 
        else acc ) 
      [] 
      (readDir dir));
  
  nixLibs = listNixNames ./.;
in
(
  lib.genAttrs 
    (nixLibs)
    (libName: import (./. + "/${libName}.nix") (args // {inherit lib;}))
)
  // { inherit lib; }.lib
  // { inherit listNixNames; }