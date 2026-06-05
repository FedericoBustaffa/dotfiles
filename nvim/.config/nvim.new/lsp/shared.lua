-- lsp/shared.lua
-- Capabilities e on_attach condivisi tra tutti i server.

local M = {}

function M.capabilities()
	return require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
end

M.on_attach = function(_, bufnr)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, silent = true, desc = desc })
	end
	map("gd", vim.lsp.buf.definition, "Go to Definition")
	map("gD", vim.lsp.buf.declaration, "Go to Declaration")
	map("gi", vim.lsp.buf.implementation, "Go to Implementation")
	map("gr", vim.lsp.buf.references, "Go to References")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
	map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
	map("<leader>ds", vim.lsp.buf.document_symbol, "Document Symbols")
end

return M
