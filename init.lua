-- This is Aaron's neovim config. Apart from plugins installed below
-- here is a list of some generic, useful vim bindings:
-- Move to left window: Ctrl-w h
-- Move to down window: Ctrl-w j
-- Move to up window: Ctrl-w k
-- Move to right window: Ctrl-w l
--
-- Scrolling page:
-- Half page down: Ctrl-d
-- Half page up: Ctrl-u
-- 
-- quickfix window navigation:
-- close: :cclose
-- 
--  Buffers:
--  :wa: write all buffers
--  leader b: list open buffers 
--  leader bd: close current buffer
--  leader y: yank visually selected text to system clipboard
-- 
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
  {  -- handles automatic copying to system clipboard over SSH
  "ojroques/nvim-osc52",
  config = function()
    require("osc52").setup()
    vim.api.nvim_set_keymap("n", "<leader>y", '<cmd>lua require("osc52").copy_operator()<CR>', {noremap=true})
    vim.api.nvim_set_keymap("v", "<leader>y", '<cmd>lua require("osc52").copy_visual()<CR>', {noremap=true})
  end
},
  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },
  {
  "smartpde/telescope-recent-files",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("recent_files")

    -- Keymap: <leader>rr opens recent files picker
    vim.keymap.set("n", "<leader>rr", function()
      require("telescope").extensions.recent_files.pick()
    end, { desc = "Telescope - Recent Files" })
  end,
},


  -- File explorer
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Formatter (Prettier, etc.)
{
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },

        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
      },

      -- Optional: if you want conform to do format-on-save globally,
      -- you can enable this. (I show a JS/TS-only autocmd below instead.)
      -- format_on_save = { timeout_ms = 1500, lsp_format = "fallback" },
    })

    -- Run formatter on-demand (normal + visual)
    vim.keymap.set({ "n", "v" }, "<leader>p", function()
      conform.format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format (Prettier via conform)" })

    -- Optional: a :Format command (handy muscle memory)
    vim.api.nvim_create_user_command("Format", function()
      conform.format({ async = true, lsp_format = "fallback" })
    end, {})
  end,
},

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

  -- Debugging
  {
    "mfussenegger/nvim-dap",
  },
  {
    "nvim-neotest/nvim-nio",  -- REQUIRED for dap-ui
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "go",
    config = function()
      require("dap-go").setup()
    end,
  },


  -- Git (minimal, powerful)
  -- Apart from key-mappings below, you can also invoke any git command with :G. E.g. :G push
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gdiffsplit", "Gblame" },
    keys = {
      { "<leader>gs", ":Git<CR>", desc = "Git status" },
      { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
      { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
      { "<leader>gp", ":Git pull<CR>", desc = "Git pull" },
      { "<leader>gps", ":Git push<CR>", desc = "Git push" },
      { "<leader>gco", ":Git push<CR>", desc = "Git checkout" },
      { "<leader>gbr", ":Git push<CR>", desc = "Git branch" },
    },
  },

   -- Copilot
  -- Open CopilotChat: <leader>cc
  -- Accept suggestion: Ctrl-J in insert mode
  -- Dismiss suggestion: Ctrl-K in insert mode
  -- Enable Copilot: <leader>ce
  -- Disable Copilot: <leader>cd
  -- To send context to chat: visually select text and press <leader>ca
  -- To send whole buffer to chat: buffer:active, enter questions and press escape and return
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
    local CopilotChat = require("CopilotChat")
    local select = require("CopilotChat.select")

    CopilotChat.setup({
      insert_mode = false,
    })

    -- Sidebar-style chat, with ENTIRE BUFFER as selection
    vim.keymap.set("n", "<leader>cc", function()
      CopilotChat.open({
        window = { layout = "vertical" },
        selection = select.buffer,
        -- optional: also make the context sticky in the chat prompt
        context = "buffer",
      })
    end, { desc = "Open Copilot Chat (buffer context)" })

    -- Ask about visual selection
    vim.keymap.set("v", "<leader>ca", function()
      local input = vim.fn.input("CopilotChat: ")
      if input ~= "" then
        CopilotChat.ask(input, {
          selection = select.visual,  -- visual selection as context
        })
      end
    end, { desc = "Ask Copilot about selection" })
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

-- Go: format + organize imports on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    -- organize imports
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end

    -- then format
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
-- vim.keymap.set("n", "K", vim.lsp.buf.hover)
-- If there are diagnostics on the current line, show them instead of hover
vim.keymap.set("n", "K", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if #diagnostics > 0 then
    -- If there are diagnostics on this line, show them
    vim.diagnostic.open_float()
  else
    -- Otherwise fall back to LSP hover
    vim.lsp.buf.hover()
  end
end, { desc = "Hover or show diagnostics" })


vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

------------------------------------------------------------
-- DAP keymaps (Go debugging)
------------------------------------------------------------
local dap = require("dap")
local dapui = require("dapui")

-- Toggle breakpoint
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "DAP: Toggle breakpoint" })

-- Run / continue
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, { desc = "DAP: Continue" })

-- Step over / into / out
vim.keymap.set("n", "<leader>do", function()
  dap.step_over()
end, { desc = "DAP: Step over" })

vim.keymap.set("n", "<leader>di", function()
  dap.step_into()
end, { desc = "DAP: Step into" })

vim.keymap.set("n", "<leader>du", function()
  dap.step_out()
end, { desc = "DAP: Step out" })

-- Toggle DAP UI (if you ever want to manually open/close)
vim.keymap.set("n", "<leader>dui", function()
  dapui.toggle()
end, { desc = "DAP: Toggle UI" })


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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt.tabstop = 4      -- how many spaces a TAB counts for visually
    vim.opt.shiftwidth = 4   -- how many spaces ">>" and "<<" indent
    vim.opt.softtabstop = 4  -- how many spaces <Tab> inserts in insert mode
  end,
})


vim.keymap.set("n", "<leader>z", "<C-l>zz", { desc = "Redraw + center screen" })

-- restore cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


------------------------------------------------------------
-- Winbar: show "won't compile" indicator for current buffer
-- (uses LSP diagnostics, e.g. gopls errors)
------------------------------------------------------------

-- Highlight groups (re-link after colorscheme changes)
local function setup_winbar_hl()
  vim.api.nvim_set_hl(0, "WinbarErr", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "WinbarOk",  { link = "DiagnosticHint" })
  vim.api.nvim_set_hl(0, "WinbarFile",{ link = "Title" })
end

setup_winbar_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_winbar_hl,
})

local function set_winbar_for(winid, bufnr)
  if not vim.api.nvim_win_is_valid(winid) then return end
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].buftype ~= "" then return end -- skip terminals, etc.

  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  if name == "" then name = "[No Name]" end

  local err_count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })

  if err_count > 0 then
    vim.api.nvim_win_set_option(winid, "winbar",
      string.format("%%#WinbarErr#✗ %d error%s%%*  %%#WinbarFile#%s%%*",
        err_count, (err_count == 1 and "" or "s"), name
      )
    )
  else
    vim.api.nvim_win_set_option(winid, "winbar",
      string.format("%%#WinbarOk#✓%%*  %%#WinbarFile#%s%%*", name)
    )
  end
end

-- Update winbar when entering buffers/windows or when diagnostics change
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  callback = function(args)
    set_winbar_for(0, args.buf)
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    -- only update if the changed diagnostics belong to the current buffer
    if args.buf == vim.api.nvim_get_current_buf() then
      set_winbar_for(0, args.buf)
    end
  end,
})

