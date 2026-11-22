local M = {}

local sioyek_instance = 'typst-nvim-' .. vim.fn.getpid()
local wiki_root = vim.fn.expand '~/dev/wiki'

local state = {
  active = false,
  watch_job = nil,
  current_file = nil,
  sioyek_job = nil,
  sioyek_pid = nil,
  autocmd_ids = {},
  compile_job = nil,
}

-- ── Utilities ───────────────────────────────────────────────────────────────

local function get_paths(file)
  file = file or vim.fn.expand '%:p'
  local pdf = vim.fn.fnamemodify(file, ':r') .. '.pdf'
  return file, pdf
end

local function typst_command(action, file)
  if vim.startswith(file, wiki_root .. '/') then
    return { 'typst', action, '--package-path', wiki_root .. '/templates', file }
  end
  return { 'typst', action, file }
end

local function is_hyprland()
  return vim.env.HYPRLAND_INSTANCE_SIGNATURE ~= nil
end

local function apply_preview_zoom(pid)
  if state.sioyek_pid == pid then
    -- Equivalent to `fw` then `+`, without focusing the preview.
    vim.fn.jobstart({ 'sioyek', '--instance-name', sioyek_instance, '--nofocus', '--execute-command', 'fit_to_page_width;zoom_in' })
  end
end

local function move_to_workspace_8(pid)
  local function try(attempt)
    if attempt > 4 then
      return
    end
    vim.defer_fn(function()
      if state.sioyek_pid ~= pid then
        return
      end
      local result = vim.fn.systemlist 'hyprctl clients -j'
      local ok, clients = pcall(vim.json.decode, table.concat(result, ''))
      if not ok or not clients then
        return
      end
      for _, client in ipairs(clients) do
        if client.pid == pid then
          local dispatch = string.format('hl.dispatch(hl.dsp.window.move({ workspace = "8", window = %q, follow = false }))', 'address:' .. client.address)
          local output = vim.fn.system { 'hyprctl', 'eval', dispatch }
          if vim.v.shell_error ~= 0 or vim.trim(output) ~= 'ok' then
            vim.notify('Typst: could not move Sioyek to workspace 8: ' .. vim.trim(output), vim.log.levels.WARN)
          end
          apply_preview_zoom(pid)
          return
        end
      end
      try(attempt + 1)
    end, attempt * 300)
  end
  try(1)
end

-- ── Viewer ──────────────────────────────────────────────────────────────────

local function close_viewer()
  local job_id = state.sioyek_job
  state.sioyek_job = nil
  state.sioyek_pid = nil
  if job_id then
    vim.fn.jobstop(job_id)
  end
end

local function open_viewer(pdf)
  if state.sioyek_job then
    local file, pid = state.current_file, state.sioyek_pid
    vim.fn.jobstart({ 'sioyek', '--instance-name', sioyek_instance, '--reuse-window', '--nofocus', pdf }, {
      on_exit = function(_, code)
        -- A separate request is needed: Sioyek runs --execute-command before opening the PDF.
        if code == 0 and state.current_file == file then
          apply_preview_zoom(pid)
        end
      end,
    })
    return
  end

  local job_id = vim.fn.jobstart({ 'sioyek', '--instance-name', sioyek_instance, '--new-window', '--nofocus', pdf }, {
    detach = true,
    on_exit = function(exited_job)
      if state.sioyek_job == exited_job then
        state.sioyek_job = nil
        state.sioyek_pid = nil
        M.stop()
      end
    end,
  })
  if job_id <= 0 then
    M.stop()
    vim.notify('Typst: could not start Sioyek', vim.log.levels.ERROR)
    return
  end
  state.sioyek_job = job_id
  state.sioyek_pid = vim.fn.jobpid(job_id)
  if is_hyprland() then
    move_to_workspace_8(state.sioyek_pid)
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
  local job_id = vim.fn.jobstart(typst_command('watch', file), {
    detach = false,
    on_exit = function(exited_job)
      if state.watch_job == exited_job then
        state.watch_job = nil
      end
    end,
  })
  state.watch_job = job_id > 0 and job_id or nil
end

-- ── Compile + open ───────────────────────────────────────────────────────────

local function activate_for_file(file)
  if state.compile_job and state.current_file == file then
    return
  end

  state.current_file = file

  start_watch(file)

  local _, pdf = get_paths(file)
  vim.notify('Typst: compiling ' .. vim.fn.fnamemodify(file, ':t') .. '...', vim.log.levels.INFO)

  local job_id = vim.fn.jobstart(typst_command('compile', file), {
    on_exit = function(exited_job, code)
      if state.compile_job ~= exited_job then
        return
      end
      state.compile_job = nil

      if code == 0 then
        open_viewer(pdf)
      else
        vim.notify('Typst: compilation failed', vim.log.levels.ERROR)
      end
    end,
  })
  state.compile_job = job_id > 0 and job_id or nil
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
        M.stop()
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
  state.compile_job = nil
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

return M
