{ inputs, lib, pkgs, config, outputs, userName, ... }: 
let
  homeDirectory = lib.mkDefault "/home/${userName}";
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

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };

    home = {
      username = userName;
      inherit homeDirectory;
      sessionPath = [ "$HOME/.local/bin" ];
      sessionVariables = 
        {FLAKE = "$HOME/NixConfig";}
        // (if (config.programs ? nixvim && config.programs.nixvim.enable) then {EDITOR = "nvim";} else {});
    };
  };
}

