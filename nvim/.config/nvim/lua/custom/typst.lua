local M = {}

local state = {
  watch_job = nil,
}

local function get_paths()
  local file = vim.fn.expand '%:p'
  local pdf = vim.fn.expand '%:p:r' .. '.pdf'
  return file, pdf
end

function M.start()
  if vim.bo.filetype ~= 'typst' then
    vim.notify('Not a Typst file', vim.log.levels.WARN)
    return
  end

  local file, pdf = get_paths()

  vim.cmd 'write'

  -- avvia watch solo se non attivo
  if not state.watch_job then
    state.watch_job = vim.fn.jobstart({ 'typst', 'watch', file }, {
      detach = false,
      on_exit = function()
        state.watch_job = nil
      end,
    })
    vim.notify 'Typst watch started'
  end

  -- APRI SEMPRE il pdf corretto
  vim.fn.jobstart({ 'zathura', pdf }, { detach = true })
end

function M.stop()
  if state.watch_job then
    vim.fn.jobstop(state.watch_job)
    state.watch_job = nil
    vim.notify 'Typst watch stopped'
  end
end

function M.toggle()
  if state.watch_job then
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
