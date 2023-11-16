{ ... }: {
  nixpkgs.hostPlatform = "x86_64-linux";

  thisConfig = {
    mainUser = "username";
    features = [
      "wsl"
      "fish"
      "nvim"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
