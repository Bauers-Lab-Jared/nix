{lib, ...}:
with lib;
with builtins; rec {
  
  SYSTEM_PERSIST = "/persist/system";
  HOME_PERSIST = username: "persist/home/${username}";

  
}
