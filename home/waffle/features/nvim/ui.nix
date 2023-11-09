{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # vim-markology
    {
      plugin = vim-fugitive;
      type = "viml";
      config = /* vim */ ''
        nmap <space>G :Git<CR>
      '';
    }
    {
      plugin = scope-nvim;
      type = "lua";
      config = /* lua */ ''
        require('scope').setup{}
      '';
    }
  ];
}
