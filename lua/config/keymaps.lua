local map = vim.keymap.set

-- ── Window navigation (smart-splits) ──────────────────────────────────────
map("n", "<C-h>", function()
	require("smart-splits").move_cursor_left()
end, { desc = "Move to left split" })
map("n", "<C-j>", function()
	require("smart-splits").move_cursor_down()
end, { desc = "Move to below split" })
map("n", "<C-k>", function()
	require("smart-splits").move_cursor_up()
end, { desc = "Move to above split" })
map("n", "<C-l>", function()
	require("smart-splits").move_cursor_right()
end, { desc = "Move to right split" })
map("n", "<C-Up>", function()
	require("smart-splits").resize_up()
end, { desc = "Resize split up" })
map("n", "<C-Down>", function()
	require("smart-splits").resize_down()
end, { desc = "Resize split down" })
map("n", "<C-Left>", function()
	require("smart-splits").resize_left()
end, { desc = "Resize split left" })
map("n", "<C-Right>", function()
	require("smart-splits").resize_right()
end, { desc = "Resize split right" })

-- Improved terminal window navigation
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal left window navigation" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal down window navigation" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal up window navigation" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal right window navigation" })
map("t", "<C-x>", [[<C-\><C-n>]], { desc = "Terminal normal mode" })

-- ── Save / quit ───────────────────────────────────────────────────────────
map("n", "<leader>w", "<cmd>w<cr>", { silent = false, desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { silent = false, desc = "Quit" })
map("n", "<leader>Q", "<cmd>qall<cr>", { silent = false, desc = "Quit all" })

-- ── Centered movement ─────────────────────────────────────────────────────
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")
map("n", "N", "Nzz")
map("n", "n", "nzz")
map("n", "G", "Gzz")
map("n", "gg", "ggzz")
map("n", "J", "mzJ`z", { desc = "Keep cursor when joining lines" })

-- ── Line start / end ──────────────────────────────────────────────────────
map("n", "L", "$", { desc = "Jump to end of line" })
map("n", "H", "^", { desc = "Jump to start of line" })

-- ── Redo ──────────────────────────────────────────────────────────────────
map("n", "U", "<C-r>", { desc = "Redo" })

-- ── Replace under cursos ──────────────────────────────────────────────────
vim.keymap.set("n", "<C-S>", function()
	local cmd = ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>"
	local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Quick find/replace" })

-- ── Splits ────────────────────────────────────────────────────────────────
map("n", "|", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "\\", "<cmd>split<cr>", { desc = "Horizontal split" })

-- ── Clipboard ─────────────────────────────────────────────────────────────
map({ "n", "x" }, "<leader>p", [["_dp]], { desc = "Paste without copying" })
map({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map({ "n", "x" }, "<leader>Y", [["+Y]], { desc = "Yank to clipboard" })
map({ "n", "x" }, "<leader>D", [["_d]], { desc = "Delete to the void" })

-- ── Visual indent ─────────────────────────────────────────────────────────
map("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
map("v", "<Tab>", ">gv", { desc = "Indent line" })

-- ── Visual line movement ──────────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- ── No-highlight ──────────────────────────────────────────────────────────
map("n", "<leader>no", "<cmd>noh<cr>", { desc = "Turn off highlighted results" })

-- ── Diagnostics ───────────────────────────────────────────────────────────
local function diag_jump(count, severity)
	return function()
		vim.diagnostic.jump({ count = count, severity = severity })
		vim.cmd("normal! zz")
	end
end

map("n", "]d", diag_jump(1), { desc = "Goto next diagnostic" })
map("n", "[d", diag_jump(-1), { desc = "Goto previous diagnostic" })
map("n", "]e", diag_jump(1, vim.diagnostic.severity.ERROR), { desc = "Goto next error" })
map("n", "[e", diag_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Goto previous error" })
map("n", "]w", diag_jump(1, vim.diagnostic.severity.WARN), { desc = "Goto next warning" })
map("n", "[w", diag_jump(-1, vim.diagnostic.severity.WARN), { desc = "Goto previous warning" })

-- ── UI toggles ────────────────────────────────────────────────────────────
local function bool2str(b)
	return b and "on" or "off"
end

-- Toggle global autoformat
map("n", "<leader>uF", function()
	vim.g.autoformat = not vim.g.autoformat
	vim.notify("Global autoformat " .. bool2str(vim.g.autoformat))
end, { desc = "Toggle autoformat (global)" })

-- Toggle buffer-local autoformat
map("n", "<leader>uf", function()
	local old = vim.b.autoformat
	if old == nil then
		old = vim.g.autoformat
	end
	vim.b.autoformat = not old
	vim.notify("Buffer autoformat " .. bool2str(vim.b.autoformat))
end, { desc = "Toggle autoformat (buffer)" })

-- Toggle spell
map("n", "<leader>us", function()
	vim.wo.spell = not vim.wo.spell
	vim.notify("Spell " .. bool2str(vim.wo.spell))
end, { desc = "Toggle spell" })

-- Toggle wrap
map("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
	vim.notify("Wrap " .. bool2str(vim.wo.wrap))
end, { desc = "Toggle wrap" })

-- Cycle line numbering
map("n", "<leader>un", function()
	local number, rnu = vim.wo.number, vim.wo.relativenumber
	if not number and not rnu then
		vim.wo.number = true
	elseif number and not rnu then
		vim.wo.relativenumber = true
	elseif number and rnu then
		vim.wo.number = false
	else
		vim.wo.relativenumber = false
	end
end, { desc = "Change line numbering" })

-- Toggle statusline (laststatus 0|2|3)
map("n", "<leader>ul", function()
	local ls = vim.opt.laststatus:get()
	vim.opt.laststatus = ls == 0 and 2 or (ls == 2 and 3 or 0)
end, { desc = "Toggle statusline" })

-- Toggle signcolumn
map("n", "<leader>ug", function()
	vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
	vim.notify("signcolumn=" .. vim.wo.signcolumn)
end, { desc = "Toggle signcolumn" })
