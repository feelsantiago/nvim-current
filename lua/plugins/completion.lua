return {
	{
		"monkoose/neocodeium",
		event = "BufEnter",
		config = function()
			local neocodeium = require("neocodeium")
			neocodeium.setup({
				-- Hide inline suggestions while the blink.cmp menu is visible.
				-- filter = function()
				-- 	return not require("blink.cmp").is_visible()
				-- end,
			})
			vim.keymap.set("i", "<A-Tab>", neocodeium.accept, { desc = "Accept Codeium suggestion" })

			-- Clear the suggestion when the completion menu opens.
			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuOpen",
				callback = function()
					neocodeium.clear()
				end,
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = "BufReadPost",
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		},
	},
	{ "xzbdmw/colorful-menu.nvim", lazy = true },
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets", "xzbdmw/colorful-menu.nvim" },
		version = "*",
		lazy = false,
		opts = {
			completion = {
				accept = {
					auto_brackets = { enabled = false },
				},
				trigger = {
					prefetch_on_insert = false,
					show_on_insert_on_trigger_character = false,
				},
				menu = {
					auto_show = true,
					border = "single",
					draw = {
						columns = { { "kind_icon" }, { "label", gap = 1 }, { "kind" } },
						components = {
							label = {
								width = { fill = true, max = 110 },
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
					window = { border = "single" },
				},
				ghost_text = { enabled = false },
			},
			cmdline = {
				enabled = true,
				completion = {
					menu = { auto_show = true },
				},
			},
			keymap = {
				preset = "enter",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
			},
			signature = { window = { border = "single" } },
			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
				kind_icons = {
					Array = " ",
					Boolean = "󰨙 ",
					Class = " ",
					Codeium = "󰘦 ",
					Color = " ",
					Control = " ",
					Collapsed = " ",
					Constant = "󰏿 ",
					Constructor = " ",
					Copilot = " ",
					Enum = " ",
					EnumMember = " ",
					Event = " ",
					Field = " ",
					File = " ",
					Folder = " ",
					Function = "󰊕 ",
					Interface = " ",
					Key = " ",
					Keyword = " ",
					Method = "󰊕 ",
					Module = " ",
					Namespace = "󰦮 ",
					Null = " ",
					Number = "󰎠 ",
					Object = " ",
					Operator = " ",
					Package = " ",
					Property = " ",
					Reference = " ",
					Snippet = "󱄽 ",
					String = " ",
					Struct = "󰆼 ",
					Supermaven = " ",
					TabNine = "󰏚 ",
					Text = " ",
					TypeParameter = " ",
					Unit = " ",
					Value = " ",
					Variable = "󰀫 ",
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
		opts_extend = {
			"sources.completion.enabled_providers",
			"sources.default",
		},
	},
}
