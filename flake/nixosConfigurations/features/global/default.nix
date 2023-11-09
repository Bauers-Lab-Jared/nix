{ inputs, outputs, ... }: {
  imports = [
    ./home-manager.nix

    ./pam.nix
    ./fish.nix
    ./locale.nix
    ./nix.nix
    ./nvim.nix
    ./git.nix
    #./openssh.nix
    #./sops.nix
    #./ssh-serve-store.nix
    ./systemd-initrd.nix
  ];

  users.mutableUsers = false;
}