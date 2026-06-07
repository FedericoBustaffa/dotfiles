return {
  -- Core DAP client
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      -- UI
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        opts = {
          icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
          layouts = {
            {
              elements = {
                { id = 'scopes', size = 0.40 },
                { id = 'breakpoints', size = 0.20 },
                { id = 'stacks', size = 0.20 },
                { id = 'watches', size = 0.20 },
              },
              size = 40,
              position = 'left',
            },
            {
              elements = {
                { id = 'repl', size = 0.5 },
                { id = 'console', size = 0.5 },
              },
              size = 12,
              position = 'bottom',
            },
          },
        },
      },

      -- Valori delle variabili inline nel buffer
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {
          commented = true, -- mostra il valore come commento
        },
      },

      -- Python: gestisce virtualenv, debugpy, test runner
      {
        'mfussenegger/nvim-dap-python',
        ft = 'python',
        config = function()
          -- debugpy installato da mason finisce qui
          local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
          local debugpy_python = mason_packages .. '/debugpy/venv/bin/python'
          require('dap-python').setup(debugpy_python)
        end,
      },

      -- Installa i debug adapter tramite mason
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        opts = {
          ensure_installed = {
            'debugpy', -- Python
            'codelldb', -- C/C++ (meglio di cppdbg: stdio redirect, meno verboso sui tipi)
          },
          -- automatic_setup = false: configuriamo noi manualmente per avere controllo pieno
          automatic_setup = false,
        },
      },
    },

    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- ── C / C++ adapter (codelldb) ──────────────────────────────────────
      -- codelldb gira come server su una porta, nvim-dap si connette via TCP
      local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
      local codelldb_path = mason_packages .. '/codelldb/extension/adapter/codelldb'

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = codelldb_path,
          args = { '--port', '${port}' },
        },
      }

      -- Configurazioni di lancio per C e C++
      -- dap.continue() mostra questo menu quando non c'è una sessione attiva
      local cpp_config = {
        {
          name = 'Launch executable',
          type = 'codelldb',
          request = 'launch',
          -- chiede il path dell'eseguibile ogni volta — utile in progetti CMake
          program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = 'Launch with args',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args = vim.fn.input 'Args: '
            return vim.split(args, ' ', { trimempty = true })
          end,
        },
        {
          name = 'Attach to process',
          type = 'codelldb',
          request = 'attach',
          pid = function()
            -- picker interattivo del PID
            return require('dap.utils').pick_process()
          end,
          args = {},
        },
      }

      dap.configurations.c = cpp_config
      dap.configurations.cpp = cpp_config

      -- ── UI: apri/chiudi automaticamente ────────────────────────────────
      -- event_initialized = il debugger è pronto e in pausa sul primo breakpoint
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- ── Keymaps ─────────────────────────────────────────────────────────
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { silent = true, desc = desc })
      end

      -- Sessione
      map('<leader>dc', dap.continue, 'DAP Continue / Start')
      map('<leader>dk', dap.terminate, 'DAP Kill')
      map('<leader>dr', dap.restart, 'DAP Restart')

      -- Breakpoints
      map('<leader>db', dap.toggle_breakpoint, 'DAP Toggle Breakpoint')
      map('<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Condition: ')
      end, 'DAP Conditional Breakpoint')
      map('<leader>dl', function()
        dap.set_breakpoint(nil, nil, vim.fn.input 'Log message: ')
      end, 'DAP Log Point')

      -- Step
      map('<leader>dso', dap.step_over, 'DAP Step Over')
      map('<leader>dsi', dap.step_into, 'DAP Step Into')
      map('<leader>dsu', dap.step_out, 'DAP Step Out')
      map('<leader>dsb', dap.step_back, 'DAP Step Back')

      -- UI manuale
      map('<leader>du', dapui.toggle, 'DAP Toggle UI')
      map('<leader>de', function()
        dapui.eval(nil, { enter = true })
      end, 'DAP Eval Expression')

      -- REPL
      map('<leader>d?', dap.repl.open, 'DAP REPL')

      -- Python-specific (disponibili solo su buffer .py)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
          local bufmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = true, silent = true, desc = desc })
          end
          local dap_py = require 'dap-python'
          bufmap('<localleader>dm', dap_py.test_method, 'DAP Python: debug method')
          bufmap('<localleader>dc', dap_py.test_class, 'DAP Python: debug class')
        end,
      })

      -- Segno breakpoint nei sign column
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '◎', texthl = 'DiagnosticInfo', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', numhl = '', linehl = 'DiffAdd' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticError', numhl = '' })
    end,

    keys = {
      { '<leader>dc', desc = 'DAP Continue' },
      { '<leader>db', desc = 'DAP Breakpoint' },
    },
  },
}
