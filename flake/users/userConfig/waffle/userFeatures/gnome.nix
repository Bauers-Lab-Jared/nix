{ lib, config, ... }: with lib; 
{
  config = {
    

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
      "org/gnome/shell" = {
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "trayIconsReloaded@selfmade.pl"
          "Vitals@CoreCoding.com"
          "dash-to-panel@jderose9.github.com"
          "sound-output-device-chooser@kgshank.net"
          "space-bar@luchrioh"
        ];
      };
    };

    home.packages = with pkgs; [
      # ...
      gnomeExtensions.user-themes
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.vitals
      gnomeExtensions.dash-to-panel
      gnomeExtensions.sound-output-device-chooser
      gnomeExtensions.space-bar
    ];

    gtk = {
      enable = true;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Catppuccin-Mocha-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "standard";
          tweaks = [ "rimless" "black" ];
          variant = "mocha";
        };
      };

      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    home.sessionVariables.GTK_THEME = "Catppuccin-Mocha-Dark";
  };
}