{
    inputs,
    outputs,
    lib,
  ...
}: {
    wslwaffle = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [ 
          ./wslwaffle.nix
          ];
      };
}