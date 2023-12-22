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
    osConfig,
    ...
}: with lib;
with lib.thisFlake;
let
  featureName = baseNameOf (toString ./.);
  cfg = config.thisFlake.homeFeatures.${featureName};
in {

  imports = [      
    
  ];

  options = mkHomeFeature {inherit osConfig featureName; otherOptions = {
      homeFeatures.${featureName} = {
        
      };
    };
  };
  
  config = mkIf cfg.enable {

    # home.file."$XDG_CONFIG_HOME/nvim/lua/init.lua" = {
    #   enable = true;
    #   source = ./lua/init.lua;
    # };

    programs.neovim = {
  		enable = true;
  		defaultEditor = true;
  		vimAlias = true;
  		viAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          vim-fugitive
          vim-rhubarb
          vim-sleuth
          nvim-lspconfig
          mason-lspconfig-nvim
          mason-nvim
          fidget-nvim
          neodev-nvim
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          friendly-snippets
          which-key-nvim
          gitsigns-nvim
          lualine-nvim
          indent-blankline-nvim
          comment-nvim
          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          nvim-treesitter-textobjects
          (nvim-treesitter.withPlugins (
            plugins: with plugins; [
              nix
              lua
            ]))
        ];

      extraPackages = with pkgs; [
        fzf
        wget
        gcc
      ];

      extraConfig = ''
        :colorscheme catppuccin
        let mapleader = " "
      '';

      extraLuaConfig = fileWithText' (./lua/init.lua) ''
        
      '';
    };
  };
}