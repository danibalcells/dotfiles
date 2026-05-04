return {
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai").setup({ palette = require("monokai").pro })
      vim.cmd.colorscheme("monokai_pro")
    end,
  },
}
