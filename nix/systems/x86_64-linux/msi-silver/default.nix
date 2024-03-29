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

    # All other arguments come from the system system.
    config,
    ...
}: with lib;
with lib.thisFlake;
let
  mainUser = "waffle";
  systemName = baseNameOf (toString ./.);
in {
	imports = [
		./hardware-configuration.nix
	];

  config = {
    networking.networkmanager.enable = true;
    users = {
	#extraUsers."root".hashedPassword = "$y$j9T$nMoJ8XuxRO5UJkUU3njPo1$mr6yrVNOb6gSNtigGEr57Zecb4AcDeJg.UInX4pqIo0";
	#users.${mainUser}.hashedPassword = "$y$j9T$nMoJ8XuxRO5UJkUU3njPo1$mr6yrVNOb6gSNtigGEr57Zecb4AcDeJg.UInX4pqIo0";
    };
    thisFlake = {

      users.${mainUser} = {
        name = mainUser;
        fullName = mainUser;
        initialPassword = "change-it";
        email = "${mainUser}@${systemName}";
        extraGroups =  [
          "wheel"
	  "video"
	  "audio"
	  "disk"
	  "input"
        ];
      };

      configFeatures = genAttrs [
      	"boot"
        "Minimal-desktop"
        "networking"
      ] (n: enabled);

      thisConfig = {
        inherit systemName mainUser;
      };
    };
    
	security.pam.services = { lightdm = {};};

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.05";
  };
}

#This system will be made available on your flake’s nixosConfigurations, 
# darwinConfigurations, or one of Snowfall Lib’s virtual *Configurations outputs
# with the same name as the directory that you created.
