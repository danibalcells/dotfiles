return {
  -- Portable package manager: installs LSP servers, linters, formatters
  { "mason-org/mason.nvim", opts = {} },

  -- Bridges mason with nvim's built-in LSP; auto-enables installed servers
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "lua_ls", "pyright", "ts_ls", "jsonls" },
    },
  },

  -- LSP configuration — uses Neovim 0.11+ vim.lsp.config() API
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Global capabilities (tells servers what the editor supports)
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- lua_ls: suppress "undefined global vim" warnings
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Keybindings set when an LSP server attaches to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition,      vim.tbl_extend("keep", opts, { desc = "Go to definition" }))
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration,     vim.tbl_extend("keep", opts, { desc = "Go to declaration" }))
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation,  vim.tbl_extend("keep", opts, { desc = "Go to implementation" }))
          vim.keymap.set("n", "gr", vim.lsp.buf.references,      vim.tbl_extend("keep", opts, { desc = "References" }))
          -- Hover / docs
          vim.keymap.set("n", "K",     vim.lsp.buf.hover,           vim.tbl_extend("keep", opts, { desc = "Hover docs" }))
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help,  vim.tbl_extend("keep", opts, { desc = "Signature help" }))
          -- Refactoring
          vim.keymap.set("n",        "<leader>rn", vim.lsp.buf.rename,       vim.tbl_extend("keep", opts, { desc = "Rename symbol" }))
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", opts, { desc = "Code action" }))
          -- Diagnostics
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("keep", opts, { desc = "Show diagnostic" }))
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,         vim.tbl_extend("keep", opts, { desc = "Prev diagnostic" }))
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next,         vim.tbl_extend("keep", opts, { desc = "Next diagnostic" }))
        end,
      })
    end,
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "buffer" }, { name = "path" } }
        ),
      })
    end,
  },

  -- Syntax highlighting via treesitter (rewritten API — no nvim-treesitter.configs)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "lua", "python", "javascript", "typescript", "tsx",
        "json", "yaml", "markdown", "bash",
      })
    end,
  },
}
