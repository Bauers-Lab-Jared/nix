{inputs, outputs, ... }: 
let
  inherit outputs;
  nixpkgs = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  system = inputs.system;
  # Supported systems for your flake packages, shell, etc.
  systems = [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
  ];

  lib = nixpkgs.lib // home-manager.lib;

  forAllSystems = nixpkgs.lib.genAttrs systems;
  forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
  pkgsFor = lib.genAttrs systems (system: import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  });

  systemNames = 
  builtins.filter (x: x != "default")
    (lib.foldlAttrs 
      (acc: name: value: 
        if value == "regular" 
        then acc ++ [
          (builtins.replaceStrings [".nix"] [""] name)] 
        else acc
      ) 
      [] 
      (builtins.readDir ./nixosConfigurations));  

in 
{
  packages = forEachSystem (pkgs: import ./customPkgs { inherit pkgs; });
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

  overlays = import ./overlays {inherit inputs outputs;};
  nixosModules = import ./nixosModules;
  homeManagerModules = import ./homeManagerModules;


  nixosConfigurations = lib.genAttrs systemNames (name:
    lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [ 
        (./nixosConfigurations + "/${name}.nix")
      ];
    }
  );
}