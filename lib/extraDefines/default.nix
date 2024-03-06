{lib, ...}:
with lib;
with builtins; rec {
  
  PERSIST_BASE = "/persist";
  PERSIST_SYSTEM = PERSIST_BASE+"/system";
  PERSIST_HOME = username: PERSIST_BASE+"/home/${username}";

  
}
