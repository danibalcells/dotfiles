return {
  -- Status line — replaces vim-airline, pure Lua
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "auto" },
      sections = {
        lualine_c = { { "filename", path = 1 } }, -- show relative path
      },
    },
  },

  -- Buffer line — visual tabs across the top for open buffers
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp", -- show LSP error/warning counts on tabs
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- Commenting — replaces NERDCommenter
  -- gcc to toggle line comment, gc in visual mode
  {
    "numToStr/Comment.nvim",
    config = true,
  },
}
