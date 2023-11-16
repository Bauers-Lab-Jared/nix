#(https://nixos.wiki/wiki/Module).
#Super Broken
let
moduleNames = 
  builtins.filter (x: x != "default")
    (lib.foldlAttrs 
      (acc: key: value: 
        if value == "regular" 
        then acc ++ [
          (builtins.replaceStrings [".nix"] [""] key)] 
        else acc
      ) 
      [] 
      (builtins.readDir ./.));
in
lib.genAttrs moduleNames (moduleName: import (./. + "/${moduleName}.nix"))
