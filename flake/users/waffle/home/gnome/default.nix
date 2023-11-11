{ pkgs, lib, config, osConfig, ... }: {
  imports = if osConfig.services.xserver.desktopManager.gnome.enable then [
    ./themes.nix
    ./extensions.nix
    ./settings.nix
  ] else [];

  
}
