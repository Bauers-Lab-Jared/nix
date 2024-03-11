{lib, ...}:
with lib;
with builtins; rec {
  
  mkSecretByHost = host: s: p: {"byHost/${host}/${s}" = {path = p;};};
  mkSecretByHost' = host: s: (mkSecretByHost host s s);
  
  mkSecretByUser = user: s: p: {"byUser/${user}/${s}" = {path = p;};};
  mkSecretByUser' = user: s: (mkSecretByUser user s s);

}
