local lsp_shared = require("config.lsp_shared")
local utils = require("config.utils")

local on_attach = lsp_shared.on_attach
local capabilities = lsp_shared.capabilities

-- Toggle the ESLint LSP client on/off
local function toggle_lint()
	local clients = vim.lsp.get_clients({ name = "eslint" })
	if #clients > 0 then
		vim.lsp.stop_client(clients[1].id)
		vim.notify("ESLint stopped", vim.log.levels.INFO)
	else
		vim.cmd("LspStart eslint")
		vim.notify("ESLint started", vim.log.levels.INFO)
	end
end

return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		opts = {
			ui = { border = "rounded" },
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost" },
		cmd = { "LspInfo", "LspInstall", "LspUninstall" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
			"j-hui/fidget.nvim",
		},
		keys = {
			{ "<leader>uL", toggle_lint, desc = "Toggle ESLint" },
		},
		config = function()
			-- Resolve the angular language server install path if available
			local angularls_cmd
			local ok, mason_registry = pcall(require, "mason-registry")
			if ok and mason_registry.is_installed("angular-language-server") then
				local angularls_path = mason_registry.get_package("angular-language-server"):get_install_path()
				angularls_cmd = {
					"ngserver",
					"--stdio",
					"--tsProbeLocations",
					table.concat({ angularls_path, vim.uv.cwd() }, ","),
					"--ngProbeLocations",
					table.concat({
						angularls_path .. "/node_modules/@angular/language-server",
						vim.uv.cwd(),
					}, ","),
				}
			end

			local servers = {
				cssls = {},
				html = {
					filetypes = { "html", "htmlangular" },
				},
				jsonls = {},
				angularls = {
					filetypes = { "typescript", "html", "htmlangular" },
					root_dir = utils.root_markers_strict({ "nx.json", "angular.json" }),
					cmd = angularls_cmd,
				},
				astro = {},
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
								library = {
									"${3rd}/luv/library",
									"${3rd}/love2d/library",
								},
							},
							telemetry = { enabled = false },
						},
					},
				},
				emmet_language_server = {},
				marksman = {},
				sqlls = {},
				tailwindcss = {
					root_dir = utils.root_markers_strict({ "tailwind.config.js", "tailwind.config.ts" }),
				},
				pylsp = {},
				denols = {
					root_dir = utils.deepest_root_dir(
						{ "deno.json", "deno.jsonc", "import_map.json" },
						{ "package.json", "tsconfig.json" }
					),
				},
				rust_analyzer = {},
				ts_ls = {
					root_dir = utils.deepest_root_dir(
						{ "tsconfig.json", "package.json" },
						{ "deno.json", "deno.jsonc", "import_map.json" }
					),
					settings = {
						maxTsServerMemory = 12000,
					},
				},
				eslint = {
					settings = {
						validate = (not utils.is_deno_project() and "on" or "off"),
					},
				},
				yamlls = {},
			}

			-- Server installs handled by mason-lspconfig; tools by mason-tool-installer
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_enable = false,
			})

			require("mason-tool-installer").setup({
				auto_update = true,
				run_on_start = true,
				start_delay = 3000,
				debounce_hours = 12,
				ensure_installed = {
					-- formatters
					"prettierd",
					"stylua",
					-- linters
					"eslint_d",
				},
			})

			-- Shared defaults applied to every server (Nvim 0.11+ native LSP config).
			-- nvim-lspconfig ships the per-server `lsp/<name>.lua` defaults on the
			-- runtimepath; these overrides are merged on top.
			--
			-- NOTE: `on_attach` is intentionally NOT set here. nvim-lspconfig ships
			-- its own `on_attach` for some servers (e.g. ts_ls, eslint); a named
			-- config overrides the wildcard `"*"` config on merge, which silently
			-- dropped our keymaps for exactly those servers. An LspAttach autocmd
			-- fires for every client regardless of config merge order, so keymaps
			-- are registered there instead.
			vim.lsp.config("*", {
				capabilities = capabilities(),
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_shared_attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						on_attach(client, args.buf)
					end
				end,
			})

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end

			vim.lsp.enable(vim.tbl_keys(servers))

			vim.diagnostic.config({
				virtual_text = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "󰌵",
						[vim.diagnostic.severity.INFO] = "󰋼",
					},
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focused = false,
					style = "minimal",
					border = "rounded",
					source = true,
					header = "",
					prefix = "",
				},
			})
		end,
	},
}
