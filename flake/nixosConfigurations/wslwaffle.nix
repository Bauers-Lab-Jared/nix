{ ... }: {
  nixpkgs.hostPlatform = "x86_64-linux";

  thisConfig = {
    mainUser = "waffle";
    features = [
      "wsl"
      "fish"
      "nvim"
      "gnome"
      "web-browsers"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
