local conform_utils = require("config.utils")

local function js_formatters()
	if conform_utils.is_deno_project() then
		return { "deno_fmt", stop_after_first = true }
	else
		return { "prettier", stop_after_first = true }
	end
end

return {
	-- ── Treesitter ─────────────────────────────────────────────────────────────
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the `main` branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"angular",
				"bash",
				"c",
				"css",
				"dart",
				"gleam",
				"graphql",
				"html",
				"java",
				"javascript",
				"jsdoc",
				"json",
				"kotlin",
				"lua",
				"markdown",
				"markdown_inline", -- separate parser on `main`; required for markdown conceal
				"ocaml",
				"ocaml_interface",
				"prisma",
				"python",
				"regex",
				"rust",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			-- Install missing parsers (async; no-op for already-installed ones).
			require("nvim-treesitter").install(parsers)

			-- Enable highlighting + treesitter indentation per buffer via FileType.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					-- Only start if a parser is available for this buffer.
					if not pcall(vim.treesitter.start, ev.buf) then
						return
					end
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- ── Treesitter textobjects ──────────────────────────────────────────────────
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			-- select (was the `select.keymaps` table)
			local sel = {
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
				al = "@loop.outer",
				il = "@loop.inner",
				ai = "@conditional.outer",
				ii = "@conditional.inner",
			}
			for lhs, cap in pairs(sel) do
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(cap, "textobjects")
				end, { desc = "TS select " .. cap })
			end

			-- move (was `move.goto_*`)
			-- stylua: ignore start
			vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
			vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Prev class start" })
			vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Prev class end" })
			-- stylua: ignore end

			-- swap (was `swap.swap_next/previous`)
			vim.keymap.set("n", "<leader>na", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap param next" })
			vim.keymap.set("n", "<leader>nb", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap param prev" })

			-- NOTE: `lsp_interop` / `peek_definition_code` (was `gp`/`gP`) was removed
			-- on the `main` branch with no built-in replacement; use LSP hover/definition.
		end,
	},

	-- ── Formatting ─────────────────────────────────────────────────────────────
	{
		"stevearc/conform.nvim",
		cmd = { "ConformInfo" },
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua", stop_after_first = true },
				javascript = js_formatters,
				typescript = js_formatters,
				html = js_formatters,
				htmlangular = js_formatters,
				css = js_formatters,
				json = js_formatters,
				markdown = { "codespell", "prettier", stop_after_first = false },
				gitcommit = { "codespell" },
				go = { "gofumpt", "golines", "goimports-reviser" },
				dart = { "dart_format" },
				rust = { "rustfmt", lsp_format = "fallback" },
			},
			format_on_save = function(bufnr)
				local enabled = vim.b[bufnr].autoformat
				if enabled == nil then
					enabled = vim.g.autoformat
				end
				if enabled and vim.bo[bufnr].filetype ~= "oil" then
					return { timeout_ms = 500, lsp_format = "fallback" }
				end
			end,
		},
		init = function()
			vim.keymap.set({ "n", "v" }, "<leader>lf", function()
				require("conform").format()
			end, { desc = "Format file" })
		end,
	},

	-- ── Motion ──────────────────────────────────────────────────────────────────
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>f1",
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
				mode = { "n", "x", "o" },
			},
			{
				"<leader>f2",
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
				mode = { "n", "x", "o" },
			},
			{
				"<leader>f3",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
				mode = "o",
			},
			{
				"<leader>f4",
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
				mode = { "o", "x" },
			},
			{
				"<c-s>",
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
				mode = "c",
			},
		},
	},

	-- ── mini.nvim collection ────────────────────────────────────────────────────
	{
		"echasnovski/mini.nvim",
		event = "VeryLazy",
		config = function()
			require("mini.ai").setup()
			require("mini.surround").setup({
				-- `s` prefix (sa/sd/sr/sf/sF/sh/sn) — kept off Flash so it's free here.
				mappings = {
					add = "sa", -- add surrounding (normal + visual)
					delete = "sd", -- delete surrounding
					replace = "sr", -- replace surrounding
					find = "sf", -- find surrounding (to the right)
					find_left = "sF", -- find surrounding (to the left)
					highlight = "sh", -- highlight surrounding
					update_n_lines = "sn", -- update `n_lines`
				},
				-- More precise targeting: also match the next surrounding when the
				-- cursor isn't already inside one (default "cover" only matches when
				-- the cursor sits within the pair, which feels like it misses).
				search_method = "cover_or_next",
				n_lines = 50,
			})
			require("mini.cursorword").setup()
			require("mini.pairs").setup()
			require("mini.move").setup({
				mappings = {
					left = "<S-h>",
					right = "<S-l>",
					down = "<S-j>",
					up = "<S-k>",
				},
			})

			-- Highlight cursor word with full visual effect
			vim.cmd("hi! link MiniCursorword Visual")
			vim.cmd("hi! MiniCursorwordCurrent gui=nocombine guifg=NONE guibg=NONE")
		end,
	},

	-- ── Comments ─────────────────────────────────────────────────────────────────
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost" },
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				opts = { enable_autocmd = false },
			},
		},
		keys = {
			{ "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
			{ "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
		},
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
			require("Comment.ft").set("reason", { "//%s", "/*%s*/" })
		end,
	},

	-- ── Todo comments ─────────────────────────────────────────────────────────────
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- ── Debug print ─────────────────────────────────────────────────────────────
	{
		"andrewferrier/debugprint.nvim",
		dependencies = { "echasnovski/mini.nvim" },
		lazy = false,
		version = "*",
		opts = {
			keymaps = {
				normal = {
					plain_below = "<leader>dp",
					plain_above = "<leader>dP",
					variable_below = "<leader>dv",
					variable_above = "<leader>dV",
					textobj_below = "<leader>do",
					textobj_above = "<leader>O",
					toggle_comment_debug_prints = "<leader>dc",
					delete_debug_prints = "<leader>dd",
				},
				visual = {
					plain_below = "<leader>dp",
					plain_above = "<leader>dP",
					variable_below = "<leader>dv",
					variable_above = "<leader>dV",
					textobj_below = "<leader>do",
					textobj_above = "<leader>O",
				},
			},
		},
	},

	-- ── Docstring generation ──────────────────────────────────────────────────────
	{
		"kkoomen/vim-doge",
		event = "BufReadPost",
		build = ":call doge#install()",
		config = function()
			vim.g.doge_enable_mappings = 0
		end,
	},
}
