{ inputs, lib, pkgs, config, outputs, userName, ... }: 
let
  environment = config.environment;
  EnabledPrograms = builtins.filter (program: program.enable ? true) environment.programs;
  additionalUserPersist = builtins.catAttrs "userPersist" EnabledPrograms;
in
{
  users.users.${userName} = {
    openssh.authorizedKeys.keys = [ (builtins.readFile (./. + "/${userName+"/ssh.pub"}")) ];
  };

  home-manager.users.${userName} = {
    imports = [ 
      (./. + "/${userName}/home")
    ];

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
    };
  };
}

