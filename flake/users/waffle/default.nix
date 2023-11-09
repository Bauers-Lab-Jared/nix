{ inputs, lib, pkgs, config, outputs, ... }:
let 
inherit config;
ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
userName = "waffle";
in
{
  #global user config
  imports = [ (import ../. {inherit inputs lib pkgs config outputs userName;}) ];

  users.users.${userName} = {
    isNormalUser = true;
    shell = (if (config.programs.fish.enable) then pkgs.fish else pkgs.bash);
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "video"
      "audio"
      "network"
      "wireshark"
      "git"
    ];
  };
}
