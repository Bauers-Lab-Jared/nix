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

  featConfig = [(WITH_HOME_FEAT_PATH {
    features = enableFeatList [
      "starship"
    ];
  })  {
    programs.bash = {
      enable = mkDefault true;
      historyControl = mkDefault ["erasedups" "ignoredups" "ignorespace"];
      historyFile = mkIf (hasFeat "system" "features" "xdg") (mkDefault "$XDG_CACHE_HOME/bash.history");
      historyIgnore = mkDefault [ "ls" "exit"];
      shellOptions = mkDefault [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
      ];
      initExtra = ''
        bind "set completion-ignore-case on"
        bind "set show-all-if-ambiguous On"
        bind "set bell-style visible"
      '';
      sessionVariables = mkDefault {
        CLICOLOR=1;
        LS_COLORS="no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:";
        #Color for manpages in less makes manpages a little easier to read
        LESS_TERMCAP_mb="\E[01;31m";
        LESS_TERMCAP_md="\E[01;31m";
        LESS_TERMCAP_me="\E[0m";
        LESS_TERMCAP_se="\E[0m";
        LESS_TERMCAP_so="\E[01;44;33m";
        LESS_TERMCAP_ue="\E[0m";
        LESS_TERMCAP_us="\E[01;32m";
      };

      shellAliases = mkDefaultEach {
        "~"="cd ~";
        ".."="cd ..";
        "..."="cd ../..";
        "...."="cd ../../..";
        "....."="cd ../../../..";

        la="ls -Alh"; # show hidden files
        ls="ls -aFh --color=always"; # add colors and file type extensions
        lx="ls -lXBh"; # sort by extension
        lk="ls -lSrh"; # sort by size
        lc="ls -lcrh"; # sort by change time
        lu="ls -lurh"; # sort by access time
        lr="ls -lRh"; # recursive ls
        lt="ls -ltrh"; # sort by date
        lm="ls -alh |more"; # pipe through "more"
        lw="ls -xAh"; # wide listing format
        ll="ls -Fls"; # long listing format
        labc="ls -lap"; #alphabetical sort
        lf="ls -l | egrep -v '^d'"; # files only
        ldir="ls -l | egrep '^d'"; # directories only

        mx="chmod a+x";
        "000"="chmod -R 000";
        "644"="chmod -R 644";
        "666"="chmod -R 666";
        "755"="chmod -R 755";
        "777"="chmod -R 777";

        h="history | grep ";

        p="ps aux | grep ";
        topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10";

        f="find . | grep ";

        openports="netstat -nape --inet";

        rebootsafe="sudo shutdown -r now";
        rebootforce="sudo shutdown -r -n now";
      };
    };
  }];
in mkFeatureFile {inherit scope featOptions featConfig imports;}
