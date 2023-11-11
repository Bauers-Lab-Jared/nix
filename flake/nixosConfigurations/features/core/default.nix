{ pkgs, lib, config, ... }: {
  # Core pakages for system
  environment.systemPackages = with pkgs; [
    wget
    curl

    alejandra # Nix formatting tool
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
  };

  imports = [
    ./home-manager.nix
    ./locale.nix
    ./pam.nix
    ./nix.nix
  ];

  
  # don't allow users to be created
  users.mutableUsers = false;
}
