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
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    in 
  {
      packages = forEachSystem (pkgs: import ./customPkgs { inherit pkgs; });
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      overlays = import ./overlays {inherit inputs outputs;};
      nixosModules = import ./nixosModules;
      homeManagerModules = import ./homeManagerModules;

      nixosConfigurations = import ./nixosConfigurations {inherit inputs outputs lib;};
  }