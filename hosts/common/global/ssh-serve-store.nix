{ config, ... }:
{
  nix = {
    sshServe = {
      enable = true;
      keys = [
        "ssh-ed25519"
      ];
      protocol = "ssh";
      write = true;
    };
    settings.trusted-users = [ "nix-ssh" ];
  };
}
