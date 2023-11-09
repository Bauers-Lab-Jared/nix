{ inputs, lib, pkgs, config, outputs, userName, ... }: {
  home-manager.users.${userName} = {
    imports = [ 
      (./. + "/${userName+"/"+config.networking.hostName+".nix"}")
    ];

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
    };
    
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        experimental-features = [ "nix-command" "flakes" "repl-flake" ];
        warn-dirty = false;
      };
    };

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };


    home = {
      username = lib.mkDefault userName;
      homeDirectory = lib.mkDefault "/home/${userName}";
      sessionPath = [ "$HOME/.local/bin" ];
      sessionVariables = {
        FLAKE = "$HOME/NixConfig";
      };

      # persistence = {
      #   "/persist/home/${userName}" = {
      #     directories = [
      #       "Workspace"
      #       "NixConfig"
      #       ".local/bin"
      #     ];
      #     allowOther = true;
      #   };
      # };
    };
  };
}
