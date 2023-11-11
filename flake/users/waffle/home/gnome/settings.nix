{ pkgs, lib, config, ... }: {
  dconf.settings = {
    
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      workspace-names = [ "Main" ];
    };
    # "org/gnome/desktop/background" = {
    #   picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
    #   picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
    # };
    # "org/gnome/desktop/screensaver" = {
    #   picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
    #   primary-color = "#3465a4";
    #   secondary-color = "#000000";
    # };
  };
}