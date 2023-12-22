{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # An instance of `pkgs` with your overlays and packages applied is also available.
    pkgs,
    # You also have access to your flake's inputs.
    inputs,

    # Additional metadata is provided by Snowfall Lib.
    system, # The system architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
    format, # A normalized name for the system target (eg. `iso`).
    virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
    systems, # An attribute map of your defined hosts.

    # All other arguments come from the module system.
    config,
    ...
}: with lib;
with lib.thisFlake;
let
  featureName = baseNameOf (toString ./.);
  cfg = config.thisFlake.configFeatures.${featureName};
in {

  imports = [      
    
  ];

  options = mkConfigFeature {inherit config featureName; 
  otherOptions = with types;{
      thisFlake.configFeatures.${featureName} = {
        
      };
    };
  };
  
  config = mkIf cfg.enable {
   environment.systemPackages = with pkgs; [
    rofi
    nitrogen
    polkit_gnome
   ];

    services = {
      xserver = {
      	enable = true;
      	layout = "us";
      	windowManager = {
		      qtile.enable = true;
      	};
        desktopManager = {
          xterm.enable = false;
        };
        displayManager = {
          lightdm.enable = true;
          defaultSession = "none+qtile";
        };
      };
      picom = {
	enable = true;
	vSync = true;
      };
    };

    programs = {
      thunar.enable = true;
      dconf.enable = true;
    };

    security = {
      polkit.enable = true;
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
        };
      };
    };
  };
}
