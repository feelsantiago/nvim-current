return {
	-- ── Terminal ───────────────────────────────────────────────────────────────
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" },
			{ "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal" },
			{ "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical" },
			{ "<F7>", '<cmd>execute v:count . "ToggleTerm"<cr>', desc = "Toggle terminal", mode = { "n", "i" } },
			{ "<C-'>", '<cmd>execute v:count . "ToggleTerm"<cr>', desc = "Toggle terminal", mode = { "n", "i" } },
			{ [[<C-\>]], '<cmd>execute v:count . "ToggleTerm"<cr>', desc = "Toggle terminal", mode = { "n", "i" } },
		},
		opts = {
			size = 10,
			on_create = function(t)
				vim.opt_local.foldcolumn = "0"
				vim.opt_local.signcolumn = "no"
				local toggle = function()
					t:toggle()
				end
				vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
				vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
					vim.keymap.set({ "n", "t", "i" }, [[<C-\>]], toggle, { desc = "Toggle terminal", buffer = t.bufnr })
			end,
			shading_factor = 2,
			direction = "float",
			float_opts = {
				border = "rounded",
				winblend = 0,
			},
		},
	},

	-- ── Trouble v3 ─────────────────────────────────────────────────────────────
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
		},
		opts = {},
	},

	-- ── Markdown ───────────────────────────────────────────────────────────────
	{
		"ellisonleao/glow.nvim",
		cmd = "Glow",
		config = true,
	},
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	},

	-- ── Quickfix ───────────────────────────────────────────────────────────────
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		opts = {
			preview = { winblend = 0 },
		},
	},

	-- ── Buffer management ────────────────────────────────────────────────────────
	{
		"kazhala/close-buffers.nvim",
		keys = {
			{
				"<leader>bd",
				function()
					require("close_buffers").delete({ type = "hidden", force = true })
				end,
				desc = "Delete all non-visible buffers",
			},
			{
				"<leader>bn",
				function()
					require("close_buffers").delete({ type = "nameless" })
				end,
				desc = "Delete all buffers without name",
			},
			{
				"<leader>bc",
				function()
					require("close_buffers").delete({ type = "this" })
				end,
				desc = "Delete the current buffer",
			},
			{
				"<leader>ba",
				function()
					require("close_buffers").wipe({ type = "all", force = true })
				end,
				desc = "Wipe all buffers",
			},
			{
				"<leader>bo",
				function()
					require("close_buffers").wipe({ type = "other" })
				end,
				desc = "Wipe all buffers except current",
			},
		},
		opts = {},
	},

	-- ── Smart splits ─────────────────────────────────────────────────────────────
	{
		"mrjones2014/smart-splits.nvim",
		lazy = true,
		opts = {
			ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
			ignored_buftypes = { "nofile" },
		},
	},

	-- ── TS error translator ─────────────────────────────────────────────────────
	{
		"dmmulroy/ts-error-translator.nvim",
		event = "BufReadPost",
		opts = {},
	},

	-- ── TypeScript type-checking ─────────────────────────────────────────────────
	{
		"dmmulroy/tsc.nvim",
		cmd = { "TSC", "TSCStop", "TSCOpen", "TSCClose" },
		opts = {
			auto_open_qflist = true,
			auto_close_qflist = false,
			auto_focus_qflist = false,
			auto_start_watch_mode = false,
			use_trouble_qflist = true,
			enable_progress_notifications = true,
			enable_error_notifications = true,
			flags = {
				noEmit = true,
				watch = false,
			},
		},
	},

	-- ── EditorConfig ─────────────────────────────────────────────────────────────
	{ "editorconfig/editorconfig-vim" },
}
