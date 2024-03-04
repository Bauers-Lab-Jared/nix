{lib, ...}:
with lib;
with builtins; rec {
  
  getEndOfPath = path: last (splitString "/" path);

}
