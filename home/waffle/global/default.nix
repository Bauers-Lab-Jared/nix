{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    #inputs.impermanence.nixosModules.home-manager.impermanence
    ../features/cli
    ../features/nvim
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
  
  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };


  home = {
    username = lib.mkDefault "waffle";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Workspace/NixConfig";
    };

    # persistence = {
    #   "/persist/home/waffle" = {
    #     directories = [
    #       "Workspace"
    #       ".local/bin"
    #     ];
    #     allowOther = true;
    #   };
    # };
  };
}
