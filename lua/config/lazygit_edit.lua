-- Open files from lazygit (kdheepak/lazygit.nvim) in the parent nvim instance.
-- lazygit runs in a terminal buffer, so nvim exports $NVIM (the parent server
-- socket); lazygit's os.edit/os.open use `nvim --server "$NVIM" --remote-send`
-- to call these globals. The <cmd>close<cr> sent first closes the lazygit float,
-- returning focus to the prior window, where we open the file.

function EditFromLazygit(file_path)
	if vim.fn.expand("%:p") == file_path then
		return
	end
	vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end

function EditLineFromLazygit(file_path, line)
	if vim.fn.expand("%:p") ~= file_path then
		vim.cmd("edit " .. vim.fn.fnameescape(file_path))
	end
	vim.cmd(tostring(line))
end
