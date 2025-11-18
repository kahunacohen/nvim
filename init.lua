------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)



------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

  -- Treesitter for syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope for fuzzy finding
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },

  -- File explorer
  { "nvim-tree/nvim-tree.lua" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin" },

})

-- Nvim-tree setup
require("nvim-tree").setup({
  -- optional configurations:
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
})

------------------------------------------------------------
-- Basic settings
------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

------------------------------------------------------------
-- Treesitter setup
------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
})

------------------------------------------------------------
-- LSP (Neovim 0.11 new API)
------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "gopls",
    "ts_ls",
    "pyright",
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  "lua_ls",
  "gopls",
  "ts_ls",
  "pyright",
}

for _, server in ipairs(servers) do
  vim.lsp.config[server] = {
    capabilities = capabilities,
  }
  vim.lsp.enable(server)
end

------------------------------------------------------------
-- Autocomplete setup
------------------------------------------------------------
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

------------------------------------------------------------
-- Keybindings
------------------------------------------------------------
vim.g.mapleader = " "

-- Nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Telescope
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>")

-- LSP basics
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.cmd.colorscheme("catppuccin")

------------------------------------------------------------
-- Done
------------------------------------------------------------
print("Neovim loaded ✨")

