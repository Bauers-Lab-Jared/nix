{ lib }:
let
  utilsDir = ./.;

  nixNamesInDir = dir: with builtins; 
      let dirReading = readDir dir; in (
        if (dirReading == {}) then [] else
          filter (x: x != "default")
          (lib.foldlAttrs 
            (acc: key: value: 
              if value == "regular" 
              then acc ++ [
                (replaceStrings [".nix"] [""] key)] 
              else acc ) 
            [] 
            (dirReading)));
in
{
  util = { inherit nixNamesInDir; } // lib.genAttrs 
    (nixNamesInDir utilsDir) (utilName: 
    (import (utilsDir + "/${utilName}.nix") 
    { inherit lib; }));
}.util