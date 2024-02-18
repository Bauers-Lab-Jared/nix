moduleArgs:
with moduleArgs.lib.thisFlake;
let
  scope = mkFeatureScope {moduleFilePath = __curPos.file; inherit moduleArgs;};
in with scope;
let
  imports = with inputs; [
    nixos-wsl.nixosModules.wsl
  ];

  options = {

  };

  config = {
    wsl = {
      enable = true;
      defaultUser = lib.mkDefault mainUser;
    };
  };
in mkFeatureFile {inherit scope options config imports;}
