local M = {}

--- Run when neovim attaches to an LSP client
function M.on_attach(client, bufnr)
	if client.name == "ts_ls" then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.name == "angularls" then
		client.server_capabilities.renameProvider = false
	end

	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	local builtin = require("telescope.builtin")

	map("n", "gd", vim.lsp.buf.definition, "LSP: Goto definition")
	map("n", "gD", vim.lsp.buf.declaration, "LSP: Goto declaration")
	map("n", "gr", builtin.lsp_references, "LSP: Goto references")
	map("n", "gI", builtin.lsp_implementations, "LSP: Goto implementation")
	map("n", "td", vim.lsp.buf.type_definition, "LSP: Type definition")
	map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
	map("n", "gl", vim.diagnostic.open_float, "LSP: Hover diagnostics")
	map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")
	map("n", "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")
	map("n", "<leader>ls", builtin.lsp_document_symbols, "LSP: Document symbols")
	map("n", "<leader>lS", builtin.lsp_workspace_symbols, "LSP: Workspace symbols")
	map("n", "<leader>lk", vim.lsp.buf.signature_help, "LSP: Signature help")
	map("n", "<leader>li", "<cmd>LspInfo<cr>", "LSP: Info")
end

--- Build the client capabilities (blink.cmp augmented)
function M.capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	return vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())
end

return M
