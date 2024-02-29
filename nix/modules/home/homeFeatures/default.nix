moduleArgs:
with moduleArgs.lib.thisFlake; {
  imports = modulePathsFromDir ./.;

  config.home.stateVersion = moduleArgs.lib.mkDefault moduleArgs.osConfig.system.stateVersion;
}

