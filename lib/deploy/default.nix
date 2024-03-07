{
    # This is the merged library containing your namespaced library as well as all libraries from
    # your flake's inputs.
    lib,

    # Your flake inputs are also available.
    inputs,

    # Additionally, Snowfall Lib's own inputs are passed. You probably don't need to use this!
    snowfall-inputs,
}: let
  inherit (inputs) deploy-rs;
in rec {
  mkDeploy = { self, overrides ? { } }:
    let
      hosts = self.nixosConfigurations or { };
      hostNames = builtins.attrNames hosts;
      nodes = lib.foldl
        (result: name:
          let
            host = hosts.${name};
            user = host.config.thisFlake.thisConfig.mainUser or null;
            inherit (host.pkgs) system;
          in
          result // {
            ${name} = (overrides.${name} or { }) // {
              hostname = overrides.${name}.hostname or "${name}";
              profiles = (overrides.${name}.profiles or { }) // {
                system = (overrides.${name}.profiles.system or { }) // {
                  path = deploy-rs.lib.${system}.activate.nixos host;
                } // lib.optionalAttrs (user != null) {
                user = "root";
                sshUser = "root";
              } // lib.optionalAttrs
                (host.config.thisFlake.security.doas.enable or false)
                {
                  sudo = "doas -u";
                };
              };
            };
          })
        { }
        hostNames;
    in
    { inherit nodes; };  

}