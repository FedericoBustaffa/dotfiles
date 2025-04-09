return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end
    },
    {
        'folke/tokyonight.nvim',
        name = 'tokyonight',
        lazy = false,
        priority = 1000,
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = false,
        priority = 1000,
    },
    {
        'Mofiqul/vscode.nvim',
        lazy = false,
        priority = 1000,
    },
}
