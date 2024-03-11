moduleArgs:
with moduleArgs.lib.thisFlake; {
  imports = modulePathsFromDir ./.;
}

