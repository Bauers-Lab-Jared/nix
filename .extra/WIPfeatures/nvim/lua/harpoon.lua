
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>k", mark.add_file)
vim.keymap.set("n", "<A-k>", ui.toggle_quick_menu)

vim.keymap.set("n", "<A-t>", function() ui.nav_file(1) end) 
vim.keymap.set("n", "<A-n>", function() ui.nav_file(2) end) 
vim.keymap.set("n", "<A-c>", function() ui.nav_file(3) end) 
vim.keymap.set("n", "<A-s>", function() ui.nav_file(4) end) 