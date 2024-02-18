moduleArgs: let
  scope = lib.thisFlake.mkFeatureScope {moduleFilePath = __curPos; inherit moduleArgs;};
in with scope;
let
  options = {

  };

  config = {
      
  };
in mkFeatureFile {inherit scope options config;} 