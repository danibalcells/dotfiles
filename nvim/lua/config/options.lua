vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.scrolloff = 15
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Use treesitter folding; start with all folds open (like foldlevel=99)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.opt.backspace = "indent,eol,start"
vim.opt.laststatus = 2

-- Show sign column always so LSP diagnostics don't shift text
vim.opt.signcolumn = "yes"

-- Faster CursorHold (for LSP hover)
vim.opt.updatetime = 300
