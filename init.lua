---------------------------------------------------------------
--- leader keys must be set before plugins are loaded
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },

  -- File explorer
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Commenting
  -- gcc  to toggle comment on current line
  -- toggle block comment: gc<number>j (to comment current line and next <number> lines)
  -- in visual mode: gc to toggle comment on selection
  {
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup()
  end,
  },

  -- Git (minimal, powerful)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gdiffsplit", "Gblame" },
    keys = {
      { "<leader>gs", ":Git<CR>", desc = "Git status" },
      { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
      { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
      { "<leader>gp", ":Git pull<CR>", desc = "Git pull" },
    },
  },

   -- Copilot
  {
    "github/copilot.vim",
    config = function()
      -- Don't use <Tab> for Copilot, let nvim-cmp keep it
      vim.g.copilot_no_tab_map = true
      -- Accept Copilot suggestion with Ctrl-J in insert mode
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', {
        silent = true,
        expr = true,
      })
    end,
  },
  {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "github/copilot.vim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("CopilotChat").setup({
      insert_mode = false,
    })

    -- Sidebar-style chat (best UX)
    vim.keymap.set("n", "<leader>cc", function()
      require("CopilotChat").open({
        window = { layout = "vertical" },
        context = "buffer",
      })
    end, { desc = "Open Copilot Chat" })

    -- Ask about selection
    vim.keymap.set("v", "<leader>ca", function()
      require("CopilotChat").ask()
    end, { desc = "Ask Copilot About Selection" })
  end,
},

  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin" },

})

-- CopilotChat: ask about a file selected via Telescope
vim.keymap.set("n", "<leader>cf", function()
  local builtin = require("telescope.builtin")

  builtin.find_files({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local action_state = require("telescope.actions.state")
        local actions = require("telescope.actions")

        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Build a #file:… reference (full path or relative — up to you)
        local file = selection.path  -- full path
        -- OR: local file = selection.filename -- relative (shorter)

        local CopilotChat = require("CopilotChat")

        -- Ask with #file:<path> prefilled
        CopilotChat.ask("#file:" .. file .. "\n\n", { jump_cursor = true })
      end)

      return true
    end,
  })
end, { desc = "CopilotChat - Ask about a selected file" })


------------------------------------------------------------
-- Basic Settings
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
-- Treesitter
------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "go",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
  },
  highlight = { enable = true },
  indent = { enable = true },
})

------------------------------------------------------------
-- LSP (Neovim 0.11 style)
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
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
      },
    },
  },
  ts_ls = {},
  pyright = {},
}

for name, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config[name] = config
  vim.lsp.enable(name)
end

-- Format Go files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

------------------------------------------------------------
-- nvim-cmp
------------------------------------------------------------
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),

  sources = {
    { name = "nvim_lsp" },
  },
})

------------------------------------------------------------
-- nvim-tree
------------------------------------------------------------
require("nvim-tree").setup({
  update_focused_file = { enable = true, update_root = false }
})

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Jump to tree
vim.keymap.set("n", "<leader>et", ":NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Go back to the previous window (buffer)
vim.keymap.set("n", "<leader>eb", ":wincmd p<CR>", { desc = "Back to previous window" })


------------------------------------------------------------
-- Telescope keymaps
------------------------------------------------------------
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>")

------------------------------------------------------------
-- LSP keymaps
------------------------------------------------------------
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

------------------------------------------------------------
-- nvim-tree keymaps
------------------------------------------------------------
vim.keymap.set("n", "<leader>er", ":NvimTreeFindFile<CR>", { desc = "Reveal current file in tree" })

-- Copilot keymaps 
-------------------------------------------------------------
vim.keymap.set("i", "<C-k>", "<Plug>(copilot-dismiss)")
vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { silent = true })
vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { silent = true })

------------------------------------------------------------
-- Colorscheme
------------------------------------------------------------
vim.cmd.colorscheme("catppuccin")


