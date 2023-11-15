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

  forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
  pkgsFor = lib.genAttrs systems (system:
    import nixpkgs {
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

  homeNames = 
  builtins.filter (x: x != "default")
    (lib.foldlAttrs 
      (acc: name: value: 
        if value == "regular" 
        then acc ++ [
          (builtins.replaceStrings [".nix"] [""] name)] 
        else acc
      ) 
      [] 
      (builtins.readDir ./homeConfigurations));  

in 
{
  inherit lib;
  
  #templates = import ./templates;
  packages = forEachSystem (pkgs: import ./customPkgs { inherit pkgs; });
  #devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});

  overlays.default = import ./overlays {inherit inputs outputs;};
  #nixosModules = import ./nixosModules;
  #homeManagerModules = import ./homeManagerModules;


  nixosConfigurations = lib.genAttrs systemNames (systemName:
    lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [ 
        (./nixosConfigurations + "/${systemName}.nix")
        ./nixosConfigurations
        ({ ... }: {thisConfig = {inherit systemName;};})
      ];

    }
  );

  # homeConfigurations = lib.genAttrs homeNames (name:
  #   lib.homeManagerConfiguration {
  #     specialArgs = {inherit inputs outputs;};
  #     modules = [ 
  #       (./homeConfigurations + "/${name}.nix")
  #     ];
  #   }
  # );
}