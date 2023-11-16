{ pkgs, lib, config, ... }: with lib;{
  
  config = {
    services.xserver =
    { 
      enable = true;
      autorun = mkDefault false;
      layout = mkDefault "us";
      displayManager = { 
          defaultSession = "gnome";
          gdm = {
          enable = true;
          wayland = false;
        };
      };
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gedit # text editor
      epiphany # web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-initial-setup
    ]);

    console.useXkbConfig = true;
    
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}