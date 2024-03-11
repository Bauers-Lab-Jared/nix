{lib, ...}:
with lib;
with builtins; rec {
  
  mkDefaultEach = atterSet: mapAttrs (name: value: mkDefault value) atterSet;

  mkDefault' = level: v: mkOverride (1000 - (level or 0)) v;
  mkDefaultEach' = level: atterSet: mapAttrs (name: value: mkDefault' level value) atterSet;

  breakdownFQDN = FQDN: let 
    nameParts = match "([^\.]+)\.{0,1}(.*)$" FQDN;
  in {
    systemName = elemAt nameParts 0;
    domain = elemAt nameParts 1;
  };
}
