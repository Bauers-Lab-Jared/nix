{ inputs, lib, pkgs, config, outputs, ... }:
let 
ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
userName = "waffle";
in
{
  #global user config
  imports = [ (import ../. {inherit inputs lib pkgs config outputs userName;}) ];

  users.users.${userName} = {
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

    openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
  };

  home-manager.users.${userName} = {
    imports = [ 
      ./features/cli
      ./features/nvim
    ];
  };
}
