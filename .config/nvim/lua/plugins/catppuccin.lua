-- Colorscheme

return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "Shatur/neovim-ayu",
        config = function()
            require("ayu").setup({
                options = {
                    theme = "ayu",
                },
            })
        end,
    },
}
