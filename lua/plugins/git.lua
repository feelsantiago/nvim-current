return {
	-- ── Gitsigns ───────────────────────────────────────────────────────────────
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"]g",
				function()
					require("gitsigns").next_hunk()
				end,
				desc = "Next git hunk",
			},
			{
				"[g",
				function()
					require("gitsigns").prev_hunk()
				end,
				desc = "Prev git hunk",
			},
			{
				"<leader>gs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "Stage hunk",
			},
			{
				"<leader>gS",
				function()
					require("gitsigns").stage_buffer()
				end,
				desc = "Stage buffer",
			},
			{
				"<leader>gh",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset hunk",
			},
			{
				"<leader>gr",
				function()
					require("gitsigns").reset_buffer()
				end,
				desc = "Reset buffer",
			},
			{
				"<leader>gu",
				function()
					require("gitsigns").undo_stage_hunk()
				end,
				desc = "Undo stage hunk",
			},
			{
				"<leader>gp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview hunk",
			},
			{
				"<leader>gl",
				function()
					require("gitsigns").blame_line()
				end,
				desc = "Blame line",
			},
			{
				"<leader>gL",
				function()
					require("gitsigns").blame_line({ full = true })
				end,
				desc = "Blame line (full)",
			},
			{
				"<leader>gd",
				function()
					require("gitsigns").diffthis()
				end,
				desc = "Diff this",
			},
		},
	},

	-- ── LazyGit + telescope git pickers ──────────────────────────────────────────
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "LazyGit" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
			{
				"<leader>gb",
				function()
					require("telescope.builtin").git_branches({ use_file_path = true })
				end,
				desc = "Git branches",
			},
			{
				"<leader>gc",
				function()
					require("telescope.builtin").git_commits({ use_file_path = true })
				end,
				desc = "Git commits (repo)",
			},
			{
				"<leader>gC",
				function()
					require("telescope.builtin").git_bcommits({ use_file_path = true })
				end,
				desc = "Git commits (file)",
			},
			{
				"<leader>gt",
				function()
					require("telescope.builtin").git_status({ use_file_path = true })
				end,
				desc = "Git status",
			},
		},
	},

	-- ── Git conflict ──────────────────────────────────────────────────────────────
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = "VeryLazy",
		config = true,
	},
}
