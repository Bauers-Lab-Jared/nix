{lib, ...}:
with lib;
with builtins; rec {
  
  SYSTEM_PERSIST = "/system";
  HOME_PERSIST = username: "/home/${username}";

  
}
