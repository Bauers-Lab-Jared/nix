{lib, ...}:
with lib;
with builtins; rec {
  
  mkDefaultEach = atterSet: mapAttrs (name: value: mkDefault value) atterSet;

}
