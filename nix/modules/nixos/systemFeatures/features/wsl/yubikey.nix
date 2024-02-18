moduleArgs:
with moduleArgs.lib.thisFlake;
let
  scope = mkFeatureScope {moduleFilePath = __curPos.file; inherit moduleArgs;};
in with scope;
let
  imports = with inputs; [
  ];

  options = {

  };

  config = {
    wsl.usbip.enable = true;
  };
in mkFeatureFile {inherit scope options config imports;}
