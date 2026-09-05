local M = {}

local state = {
  active = false,
  watch_job = nil,
  current_file = nil,
  sioyek_pid = nil,
  autocmd_ids = {},
  pending_open = false,
}

-- ── Utilities ───────────────────────────────────────────────────────────────

local function get_paths(file)
  file = file or vim.fn.expand '%:p'
  local pdf = vim.fn.fnamemodify(file, ':r') .. '.pdf'
  return file, pdf
end

local function is_hyprland()
  return vim.env.HYPRLAND_INSTANCE_SIGNATURE ~= nil
end

local function move_to_workspace_8(pid)
  local function try(attempt)
    if attempt > 4 then
      return
    end
    vim.defer_fn(function()
      local result = vim.fn.systemlist 'hyprctl clients -j'
      local ok, clients = pcall(vim.json.decode, table.concat(result, ''))
      if not ok or not clients then
        return
      end
      for _, client in ipairs(clients) do
        if client.pid == pid then
          vim.fn.system('hyprctl dispatch movetoworkspacesilent 8,address:' .. client.address)
          return
        end
      end
      try(attempt + 1)
    end, attempt * 300)
  end
  try(1)
end

-- ── Viewer ──────────────────────────────────────────────────────────────────

-- Controlla se il processo del plugin è ancora vivo
local function viewer_alive()
  if not state.sioyek_pid then
    return false
  end
  local res = vim.fn.system('kill -0 ' .. state.sioyek_pid .. ' 2>/dev/null; echo $?')
  return vim.trim(res) == '0'
end

local function close_viewer()
  if state.sioyek_pid then
    -- SIGTERM solo sulla finestra del plugin, non tocca le altre
    vim.fn.system('kill ' .. state.sioyek_pid)
    state.sioyek_pid = nil
  end
end

local function open_viewer(pdf)
  if viewer_alive() then
    -- Riusa la finestra già aperta dal plugin: cambia solo il PDF
    -- --nofocus evita di rubare il focus dall'editor
    vim.fn.jobstart({ 'sioyek', '--reuse-window', '--nofocus', pdf }, { detach = true })
  else
    -- Prima apertura (o finestra chiusa manualmente dall'utente)
    local job_id = vim.fn.jobstart({ 'sioyek', '--new-window', pdf }, {
      detach = true,
      on_exit = function()
        state.sioyek_pid = nil
      end,
    })
    state.sioyek_pid = vim.fn.jobpid(job_id)

    if is_hyprland() then
      move_to_workspace_8(state.sioyek_pid)
    end
  end
end

-- ── Watch ────────────────────────────────────────────────────────────────────

local function stop_watch()
  if state.watch_job then
    vim.fn.jobstop(state.watch_job)
    state.watch_job = nil
  end
end

local function start_watch(file)
  stop_watch()
  state.watch_job = vim.fn.jobstart({ 'typst', 'watch', file }, {
    detach = false,
    on_exit = function()
      state.watch_job = nil
    end,
  })
end

-- ── Compile + open ───────────────────────────────────────────────────────────

local function activate_for_file(file)
  if state.pending_open and state.current_file == file then
    return
  end

  state.current_file = file
  state.pending_open = true

  start_watch(file)

  local _, pdf = get_paths(file)
  vim.notify('Typst: compiling ' .. vim.fn.fnamemodify(file, ':t') .. '...', vim.log.levels.INFO)

  vim.fn.jobstart({ 'typst', 'compile', file }, {
    on_exit = function(_, code)
      state.pending_open = false
      if state.current_file ~= file then
        return
      end

      if code == 0 then
        open_viewer(pdf)
      else
        vim.notify('Typst: compilation failed', vim.log.levels.ERROR)
      end
    end,
  })
end

-- ── Autocmds ─────────────────────────────────────────────────────────────────

local function clear_autocmds()
  for _, id in ipairs(state.autocmd_ids) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  state.autocmd_ids = {}
end

local function setup_autocmds()
  local id1 = vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.typ',
    callback = function()
      if not state.active then
        return
      end
      local file = vim.fn.expand '%:p'
      if file == '' or file == state.current_file then
        return
      end
      vim.cmd 'write'
      activate_for_file(file)
    end,
  })

  local id2 = vim.api.nvim_create_autocmd('BufDelete', {
    pattern = '*.typ',
    callback = function()
      if not state.active then
        return
      end

      local closed_file = vim.fn.expand '<afile>:p'
      local remaining = vim
        .iter(vim.fn.getbufinfo { buflisted = 1 })
        :filter(function(b)
          return vim.fn.fnamemodify(b.name, ':e') == 'typ' and b.name ~= closed_file
        end)
        :totable()

      if #remaining == 0 then
        stop_watch()
        close_viewer()
        state.current_file = nil
      elseif closed_file == state.current_file then
        activate_for_file(remaining[1].name)
      end
    end,
  })

  state.autocmd_ids = { id1, id2 }
end

-- ── Public API ───────────────────────────────────────────────────────────────

function M.start()
  if vim.bo.filetype ~= 'typst' then
    vim.notify('Not a Typst file', vim.log.levels.WARN)
    return
  end
  state.active = true
  vim.cmd 'write'
  setup_autocmds()
  activate_for_file(vim.fn.expand '%:p')
end

function M.stop()
  state.active = false
  stop_watch()
  close_viewer()
  clear_autocmds()
  state.current_file = nil
  state.pending_open = false
  vim.notify('Typst: stopped', vim.log.levels.INFO)
end

function M.toggle()
  if state.active then
    M.stop()
  else
    M.start()
  end
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    M.stop()
  end,
})

vim.keymap.set('n', '<localleader>ty', M.toggle, { desc = 'Typst Preview' })

return M
