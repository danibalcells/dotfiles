return {
  -- Fuzzy finder — replaces fzf.vim; keeps your `;` binding for files
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({ "telescope" }) -- telescope-like layout

      -- Mirror old `;` → :Files mapping
      vim.keymap.set("n", ";", fzf.files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
      -- LSP pickers (also used by lsp on_attach for references/definitions)
      vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
      vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
    end,
  },

  -- File tree sidebar — replaces Tagbar for file-level navigation
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_current",
        },
      })
      -- Mirror old <leader>tt / <leader>tr tagbar bindings
      vim.keymap.set("n", "<leader>tt", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>tr", "<cmd>Neotree reveal<CR>", { desc = "Reveal file in tree" })
    end,
  },
}
