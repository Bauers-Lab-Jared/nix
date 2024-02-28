
require("nvim-treesitter.configs").setup({
    ensure_installed = {},
    auto_install = false,
    indent = { enable = true },
    highlight = {
        enable = true, 
        additional_vim_regex_highlighting = false,
        disable = {}, -- treesitter interferes with VimTex
    },
})