{ config, osConfig, pkgs, lib, inputs, ... }: {
  
  config.programs.neovim = let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    fromFile = file: (builtins.readFile file);
  in
  lib.mkIf osConfig.programs.neovim.enable {

    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./lua/options.lua}
    '';

    extraPackages = with pkgs; [
      lua-language-server
      rnix-lsp

      xclip
      wl-clipboard
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      plenary-nvim

      {
        plugin = nightfox-nvim;
        type = "lua";
        config = fromFile ./lua/plugin/nightfox-nvim.lua;
      }

      mini-nvim
    ];
  };
}