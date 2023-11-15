{featureName}: {inputs, lib, config, ... }: with lib; 
let
  cfg = config.homeFeatures.${featureName};
in
{

  imports = [      
    inputs.nixvim.homeManagerModules.nixvim
  ];

  options.homeFeatures.${featureName}.enable =
    mkEnableOption "general config for nixvim";

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = mkDefault true;

      globals.mapleader = mkDefault " ";

      defaultEditor = mkDefault true;
      viAlias = mkDefault true;
      vimAlias = mkDefault true;

      options = {
          nu = mkDefault true;
          relativenumber = mkDefault true;
          tabstop = mkDefault 4;
          softtabstop = mkDefault 4;
          shiftwidth = mkDefault 4;
          expandtab = mkDefault true;
          smartindent = mkDefault true;
          wrap = mkDefault false;
          swapfile = mkDefault false;
          backup = mkDefault false;
          undodir = mkDefault "os.getenv(\"HOME\") .. \"/.nvim/undodir\"";
          undofile = mkDefault true;
          hlsearch = mkDefault false;
          incsearch = mkDefault true;
          termguicolors = mkDefault true;
          scrolloff = mkDefault 8;
          updatetime = mkDefault 50;
      };

      colorschemes.catppuccin = {
        enable = mkDefault true;

        flavour = mkDefault "mocha";
        terminalColors = mkDefault true; 
        background.dark = mkDefault "mocha";
        dimInactive.enabled = mkDefault true;
      };
    };

    home.sessionVariables = {
      EDITOR = mkDefault "nvim";
    };
  };
}