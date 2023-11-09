{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
        local lspconfig = require('lspconfig')

        function add_lsp(binary, server, options)
          if not options["cmd"] then options["cmd"] = { binary, unpack(options["cmd_args"] or {}) } end
          if vim.fn.executable(binary) == 1 then server.setup(options) end
        end

        add_lsp("gopls", lspconfig.gopls, {})
        add_lsp("tsserver", lspconfig.tsserver, {})
        add_lsp("lua-lsp", lspconfig.lua_ls, {})
      '';
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim
    {
      plugin = nvim-cmp;
      type = "lua";
      config = /* lua */ ''
        local cmp = require('cmp')

        cmp.setup{
          formatting = { format = require('lspkind').cmp_format() },
          -- Same keybinds as vim's vanilla completion
          mapping = {
            ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-y>'] = cmp.mapping.confirm(),
          },
          sources = {
            { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
            { name='nvim_lsp' },
          },
        }
      '';
    }
  ];
}
