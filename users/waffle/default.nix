{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.waffle = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "video"
      "audio"
      "network"
      "wireshark"
      "git"
    ];

    openssh.authorizedKeys.keys = [ (builtins.readFile ../../home/waffle/ssh.pub) ];
  };

  home-manager.users.waffle = import ../../home/waffle/${config.networking.hostName}.nix;

  security.pam.services = { swaylock = { }; };
}
