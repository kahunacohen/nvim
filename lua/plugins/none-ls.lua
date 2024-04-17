return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.gofumpt,
            null_ls.builtins.formatting.prettier,
        })
        vim.keymap.set("n", "<leader>fmt", vim.lsp.buf.format, {})
    end
}
