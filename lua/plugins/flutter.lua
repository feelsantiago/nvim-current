local lsp_shared = require("config.lsp_shared")

return {
	"akinsho/flutter-tools.nvim",
	lazy = false,
	dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
	config = function()
		require("flutter-tools").setup({
			ui = { border = "rounded", notification_style = "native" },
			decorations = { statusline = { app_version = true, device = true } },
			widget_guides = { enabled = true },
			closing_tags = { highlight = "ErrorMsg", prefix = "//", enabled = true },
			dev_log = { enabled = true, open_cmd = "tabedit" },
			dev_tools = { autostart = false, auto_open_browser = false },
			outline = { open_cmd = "30vnew", auto_open = false },
			lsp = {
				on_attach = lsp_shared.on_attach,
				capabilities = lsp_shared.capabilities(),
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					analysisExcludedFolders = { vim.fn.expand("$HOME/.pub-cache") },
				},
			},
		})
	end,
	keys = {
		{ "<leader>Ff", "<cmd>Telescope flutter commands<cr>", desc = "Flutter commands" },
		{ "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter emulators" },
		{ "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter devices" },
		{ "<leader>Fr", "<cmd>FlutterReload<cr>", desc = "Flutter reload" },
		{ "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter restart" },
		{ "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter outline" },
		{ "<leader>Fs", "<cmd>FlutterRun<cr>", desc = "Flutter run" },
		{ "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter quit" },
	},
}
