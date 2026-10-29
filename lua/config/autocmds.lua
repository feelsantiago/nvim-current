local augroup = function(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

-- ── Highlight on yank ─────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	pattern = "*",
	desc = "Highlight selection on yank",
	callback = function()
		vim.hl.on_yank({ timeout = 200, visual = true })
	end,
})

-- ── Auto-resize windows on terminal resize ────────────────────────────────
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_windows"),
	pattern = "*",
	command = "wincmd =",
	desc = "Auto-resize windows on terminal buffer resize",
})

-- ── Make q close help / nofile / quickfix / oil ───────────────────────────
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = augroup("q_close_windows"),
	desc = "Make q close help, nofile, quickfix and oil windows",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		local defaults = vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype)
		local is_oil = vim.bo[args.buf].filetype == "oil"
		if (defaults or is_oil) and vim.fn.maparg("q", "n") == "" then
			vim.keymap.set("n", "q", "<cmd>close<cr>", {
				desc = "Close window",
				buffer = args.buf,
				silent = true,
				nowait = true,
			})
		end
	end,
})

-- ── Clear jump list on start ──────────────────────────────────────────────
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("clear_jumps"),
	pattern = "*",
	desc = "Clear jump list on start",
	callback = function()
		vim.cmd("clearjumps")
	end,
})

-- ── Spell + wrap for prose filetypes ──────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("edit_text"),
	pattern = { "gitcommit", "markdown", "txt" },
	desc = "Enable spell checking and text wrapping for certain filetypes",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- ── Restore cursor to last known position ─────────────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("restore_cursor"),
	desc = "Restore cursor to last known position",
	callback = function(args)
		local exclude = { "gitcommit", "gitrebase" }
		if vim.tbl_contains(exclude, vim.bo[args.buf].filetype) then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- ── Auto-create missing parent directories on save ────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_create_dirs"),
	desc = "Auto-create missing parent directories on save",
	callback = function(args)
		if args.match:match("^%w%w+://") then
			return
		end
		local file = vim.uv.fs_realpath(args.match) or args.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- ── Reload files changed outside of nvim ──────────────────────────────────
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = augroup("auto_reload"),
	desc = "Reload files changed outside of nvim",
	callback = function()
		if vim.bo.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- ── Restart treesitter after an external reload (keeps highlight in sync) ─
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("auto_reload"),
	desc = "Restart treesitter parser after external file reload",
	callback = function(ev)
		pcall(vim.treesitter.stop, ev.buf)
		pcall(vim.treesitter.start, ev.buf)
	end,
})

-- ── Warn loudly when an external change can't be auto-merged ─────────────
-- With cmdheight=0 vim's default "W12: file changed and buffer changed too"
-- message never shows, so a stale buffer (e.g. agent wrote the file while you
-- were mid-edit) silently diverges from disk. Further edits build on that
-- stale base and corrupt LSP/treesitter state until a manual :e. Surface it.
vim.api.nvim_create_autocmd("FileChangedShell", {
	group = augroup("warn_reload_conflict"),
	desc = "Notify when a buffer can't auto-reload due to local edits",
	callback = function(args)
		vim.v.fcs_choice = ""
		vim.notify(
			"File changed on disk but buffer has unsaved edits — stale until :e! or :diffthis. "
				.. vim.fn.fnamemodify(args.file, ":."),
			vim.log.levels.WARN,
			{ title = "Buffer out of sync" }
		)
	end,
})

-- ── BufSyncCheck command ──────────────────────────────────────────────────
-- Debug helper: dump LSP/treesitter/buffer state to spot desync before
-- reaching for :e. Run when highlighting/diagnostics look wrong.
vim.api.nvim_create_user_command("BufSyncCheck", function()
	local buf = vim.api.nvim_get_current_buf()
	local lines = {}

	table.insert(lines, "buf " .. buf .. ": " .. vim.api.nvim_buf_get_name(buf))
	table.insert(
		lines,
		"modified=" .. tostring(vim.bo[buf].modified) .. " changedtick=" .. vim.api.nvim_buf_get_changedtick(buf)
	)

	local clients = vim.lsp.get_clients({ bufnr = buf })
	if #clients == 0 then
		table.insert(lines, "lsp: none attached")
	else
		for _, c in ipairs(clients) do
			local ok_ver, doc_ver = pcall(function()
				return vim.lsp.util.buf_versions[buf]
			end)
			table.insert(
				lines,
				string.format(
					"lsp: %s id=%d offset_encoding=%s doc_version=%s",
					c.name,
					c.id,
					c.offset_encoding,
					ok_ver and tostring(doc_ver) or "?"
				)
			)
		end
	end

	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if ok and parser then
		local tree = parser:parse()[1]
		if tree then
			table.insert(lines, "treesitter: parser ok, root range=" .. vim.inspect({ tree:root():range() }))
		else
			table.insert(lines, "treesitter: parser exists but parse() returned no tree")
		end
	else
		table.insert(lines, "treesitter: none/error " .. tostring(parser))
	end

	local path = vim.api.nvim_buf_get_name(buf)
	if path ~= "" then
		local stat = vim.uv.fs_stat(path)
		if stat then
			table.insert(lines, "disk mtime=" .. os.date("%H:%M:%S", stat.mtime.sec) .. " size=" .. stat.size)
		end
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "BufSyncCheck" })
end, { desc = "Dump buffer/LSP/treesitter sync state for debugging desync" })

-- ── RotateWindows command ─────────────────────────────────────────────────
vim.api.nvim_create_user_command("RotateWindows", function()
	local ignored_filetypes = { "neo-tree", "fidget", "Outline", "toggleterm", "qf", "notify" }
	local window_numbers = vim.api.nvim_tabpage_list_wins(0)
	local windows_to_rotate = {}

	for _, window_number in ipairs(window_numbers) do
		local buffer_number = vim.api.nvim_win_get_buf(window_number)
		local filetype = vim.bo[buffer_number].filetype

		if not vim.tbl_contains(ignored_filetypes, filetype) then
			table.insert(windows_to_rotate, { window_number = window_number, buffer_number = buffer_number })
		end
	end

	local num_eligible_windows = vim.tbl_count(windows_to_rotate)

	if num_eligible_windows == 0 then
		return
	elseif num_eligible_windows == 1 then
		vim.api.nvim_err_writeln("There is no other window to rotate with.")
		return
	elseif num_eligible_windows == 2 then
		local first_window = windows_to_rotate[1]
		local second_window = windows_to_rotate[2]

		vim.api.nvim_win_set_buf(first_window.window_number, second_window.buffer_number)
		vim.api.nvim_win_set_buf(second_window.window_number, first_window.buffer_number)
	else
		vim.api.nvim_err_writeln("You can only swap 2 open windows. Found " .. num_eligible_windows .. ".")
	end
end, {})
