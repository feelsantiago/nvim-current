return {
	-- ── Telescope ──────────────────────────────────────────────────────────────
	{
		"nvim-telescope/telescope.nvim",
		-- `master` (not the 0.1.x release branch) uses native vim.treesitter for
		-- preview highlighting; 0.1.x calls nvim-treesitter's removed `ft_to_lang`
		-- API and crashes against the nvim-treesitter `main` branch.
		branch = "master",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{
				"<leader>fF",
				function()
					require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
				end,
				desc = "Find all files",
			},
			{ "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{
				"<leader>fW",
				function()
					require("telescope.builtin").live_grep({
						additional_args = function(args)
							return vim.list_extend(args, { "--hidden", "--no-ignore" })
						end,
					})
				end,
				desc = "Live grep (all files)",
			},
			{ "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find open buffers" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
			{
				"<leader>fn",
				function()
					require("telescope").extensions.notify.notify()
				end,
				desc = "Find notifications",
			},
			{
				"<leader>fN",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find nvim config files",
			},
			{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Find diagnostics" },
			{ "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
			{ "<leader>f<cr>", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
			{ "<leader>f'", "<cmd>Telescope marks<cr>", desc = "Find marks" },
			{ "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Find registers" },
			{
				"<leader>f/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find(
						require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
					)
				end,
				desc = "Fuzzy search current buffer",
			},
			{
				"<leader>uD",
				function()
					require("notify").dismiss({ pending = true, silent = true })
				end,
				desc = "Dismiss notifications",
			},
		},
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					path_display = { "truncate" },
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = { prompt_position = "top", preview_width = 0.55 },
						vertical = { mirror = false },
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-x>"] = actions.delete_buffer,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
						n = {
							q = actions.close,
							["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
					},
					file_ignore_patterns = { "node_modules/", "%.git/" },
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "notify")
		end,
	},

	-- ── Harpoon v2 ─────────────────────────────────────────────────────────────
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
		keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon add file",
			},
			{
				"<leader>ho",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon menu",
			},
			{
				"<leader>hr",
				function()
					require("harpoon"):list():remove()
				end,
				desc = "Harpoon remove file",
			},
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon file 1",
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon file 2",
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon file 3",
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon file 4",
			},
			{
				"<leader>5",
				function()
					require("harpoon"):list():select(5)
				end,
				desc = "Harpoon file 5",
			},
		},
	},

	-- ── Oil ────────────────────────────────────────────────────────────────────
	{
		"stevearc/oil.nvim",
		-- Load at startup (not just on the keymap) so oil can hijack the directory
		-- buffer when nvim is opened on a folder, e.g. `nvim .`.
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>e",
				function()
					require("oil").toggle_float()
				end,
				desc = "Toggle file explorer",
			},
		},
		opts = {
			use_default_keymaps = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["S"] = "actions.select_split",
				["s"] = "actions.select_vsplit",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-r>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["H"] = "actions.toggle_hidden",
			},
			view_options = {
				show_hidden = true,
			},
			float = {
				win_options = { winblend = 0 },
			},
		},
		config = function(_, opts)
			require("oil").setup(opts)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "oil",
				callback = function()
					vim.opt_local.colorcolumn = ""
				end,
			})
		end,
	},

	-- ── Spectre (search/replace) ─────────────────────────────────────────────────
	{
		"nvim-pack/nvim-spectre",
		cmd = { "Spectre" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>ss",
				function()
					require("spectre").toggle()
				end,
				desc = "Open Spectre",
			},
			{
				"<leader>sw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word",
			},
		},
		config = function()
			vim.api.nvim_set_hl(0, "SpectreSearch", { bg = "#bf616a", fg = "#2e3440" })
			vim.api.nvim_set_hl(0, "SpectreReplace", { bg = "#a3be8c", fg = "#2e3440" })

			require("spectre").setup({
				highlight = {
					search = "SpectreSearch",
					replace = "SpectreReplace",
				},
				mapping = {
					["send_to_qf"] = {
						map = "<C-q>",
						cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
						desc = "send all items to quickfix",
					},
				},
			})
		end,
	},

	-- ── Aerial (symbol outline) ────────────────────────────────────────────────
	{
		"stevearc/aerial.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<leader>lo", "<cmd>AerialToggle<cr>", desc = "LSP: Toggle outline (aerial)" },
		},
		opts = {
			attach_mode = "global",
			backends = { "lsp", "treesitter", "markdown", "man" },
			layout = { min_width = 28 },
			show_guides = true,
			filter_kind = false,
			guides = {
				mid_item = "├ ",
				last_item = "└ ",
				nested_top = "│ ",
				whitespace = "  ",
			},
			keymaps = {
				["[y"] = "actions.prev",
				["]y"] = "actions.next",
				["[Y"] = "actions.prev_up",
				["]Y"] = "actions.next_up",
				["{"] = false,
				["}"] = false,
				["[["] = false,
				["]]"] = false,
			},
		},
	},
}
