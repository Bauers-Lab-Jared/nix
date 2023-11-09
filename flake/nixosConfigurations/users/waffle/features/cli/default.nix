{ pkgs, inputs, ... }: {
  imports = [
    ./bash.nix
    ./fish.nix
    ./gh.nix
    ./git.nix
    #./ssh.nix
  ];
  home.packages = with pkgs; [

  ];
}
