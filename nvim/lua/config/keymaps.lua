local map = vim.keymap.set

-- Mirror .vimrc behaviour
map("n", "·", "^")
map("n", "j", "gj")
map("n", "k", "gk")

-- Buffer navigation (TAB / S-TAB like before; bufferline-aware)
map("n", "<TAB>", "<cmd>BufferLineCycleNext<CR>")
map("n", "<S-TAB>", "<cmd>BufferLineCyclePrev<CR>")

-- Window navigation
map("n", "<C-J>", "<C-W><C-J>")
map("n", "<C-K>", "<C-W><C-K>")
map("n", "<C-L>", "<C-W><C-L>")
map("n", "<C-H>", "<C-W><C-H>")

-- Indent and keep visual selection
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Fold toggle
map("n", "<space>", "za")

-- LSP — set in plugins/lsp.lua via on_attach so they're buffer-local
-- gd  → go to definition
-- K   → hover docs
-- gr  → references
-- gi  → implementation
-- <leader>rn → rename
-- <leader>ca → code action
-- <leader>d  → show diagnostics float
