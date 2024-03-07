moduleArgs@{
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
    osConfig,
    ...
}:
with moduleArgs.lib.thisFlake;
let
  scope = mkFeatureScope {moduleFilePath = __curPos.file; inherit moduleArgs;};
in with scope;
let
  imports = with inputs; [
  ];

  featOptions = with types; {

  };

  featConfig = {
    home.sessionVariables = {
      STARSHIP_CONFIG = "$XDG_CONFIG_HOME/starship.toml";
      STARSHIP_CACHE = "$XDG_CACHE_HOME/starship/cache";
    };

    programs.starship = mkDefaultEach {
      enable = true;
      settings = {
        command_timeout = 5000;
        format = concatStrings [
          "[](#3B4252)"
          "$username"
          "$ssh_symbol"
          "$hostname"
          "[](bg:#434C5E fg:#3B4252)"
          "$directory"
          "[](fg:#434C5E bg:#4C566A)"
          "$git_branch"
          "$git_status"
          "[](fg:#4C566A bg:#86BBD8)"
          "[ ](fg:#33658A)\n"
          "$status"
          "|>"
        ];
        hostname = {
          style = "bg:#3B4252";
          format = "[$ssh_symbol$hostname ]($style)";
        };
        status = {
          disabled = false;
        };
        username = {
          show_always = true;
          style_user = "bg:#3B4252";
          style_root = "bg:#3B4252";
          format = "[$user]($style)";
        };
        directory = {
          style = "bg:#434C5E";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        git_branch = {
          symbol = "";
          style = "bg:#4C566A";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:#4C566A";
          format = "[$all_status $ahead_behind]($style)";
        };
      };
    };
  };
in mkFeatureFile {inherit scope featOptions featConfig imports;}
