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
    inputs.nixvim.nixosModules.nixvim
  ];

  options = mkConfigFeature {inherit config featureName; 
  otherOptions = with types;{
      configFeatures.${featureName} = {
        
      };
    };
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fzf
    ];

    programs.neovim = {
  		enable = true;
  		defaultEditor = true;
  		vimAlias = true;
  		viAlias = true;
  		
  		configure = {packages.myVimPackage = with pkgs.vimPlugins; {
		    start = [
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

          (pkgs.vimUtils.buildVimPlugin {
              name = "nvim-config";
              src = ./neovim-config;
            })
        ];};

		customRC = ''
		  :colorscheme catppuccin
      lua require("init")
		'';};
  	};
  };
}