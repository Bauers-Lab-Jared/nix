{lib, ...}:
with lib;
with builtins; rec {
  
  PERSIST_BASE = "/persist";
  PERSIST_SYSTEM = PERSIST_BASE+"/system";
  PERSIST_SYSTEM_HOMES = "/.persist";
  PERSIST_HOME = username: PERSIST_BASE;

  USER_HOME_LOCATION = username: "/home/${username}";
  
}
