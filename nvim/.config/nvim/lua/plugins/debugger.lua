return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'jay-babu/mason-nvim-dap.nvim',
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    require('mason-nvim-dap').setup {
      ensure_installed = { 'cppdbg', 'python' },
      automatic_installation = true,
      handlers = {
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue' })
    vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Inspect' })
    vim.keymap.set('n', '<leader>dk', dap.terminate, { desc = 'Kill' })

    vim.keymap.set('n', '<leader>dso', dap.step_over, { desc = 'Step Over' })
    vim.keymap.set('n', '<leader>dsi', dap.step_into, { desc = 'Step Into' })
    vim.keymap.set('n', '<leader>dsu', dap.step_out, { desc = 'Step Out' })
    vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Run Last' })

    vim.keymap.set('n', '<leader>duu', dapui.open, { desc = 'Open Debuggger' })
    vim.keymap.set('n', '<leader>duc', dapui.close, { desc = 'Close Debuggger' })
  end,
}
