local M = {}

--- Check if a plugin is defined in lazy (useful before it is loaded)
---@param plugin string
---@return boolean
function M.is_available(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

--- Parse an integer color to a hex string
---@param int_color number
function M.parse_hex(int_color)
	return string.format("#%x", int_color)
end

--- Get highlight properties for a given highlight name
---@param name string
---@param fallback? table
---@return table
function M.get_hlgroup(name, fallback)
	if vim.fn.hlexists(name) == 1 then
		local group = vim.api.nvim_get_hl(0, { name = name })
		return {
			fg = group.fg == nil and "NONE" or M.parse_hex(group.fg),
			bg = group.bg == nil and "NONE" or M.parse_hex(group.bg),
		}
	end
	return fallback or {}
end

--- Count open, named buffers
---@return number
function M.get_buffer_count()
	local count = 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.fn.bufname(buf) ~= "" then
			count = count + 1
		end
	end
	return count
end

--- Build a `vim.lsp.Config.root_dir` function (Nvim 0.11+) that attaches a server
--- only when one of `markers` is found in an ancestor directory.
---@param markers string[]
function M.root_markers_strict(markers)
	return function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, markers)
		if root then
			on_dir(root)
		end
	end
end

--- Build a `vim.lsp.Config.root_dir` function (Nvim 0.11+) that resolves to the
--- deepest match between two sets of root markers, used to disambiguate
--- overlapping servers (e.g. ts_ls / denols). The server attaches only when a
--- `patterns1` match exists and is deeper than (or in the absence of) a
--- `patterns2` match.
function M.deepest_root_dir(patterns1, patterns2)
	return function(bufnr, on_dir)
		local startpath = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
		local path1 = vim.fs.root(startpath, patterns1)
		local path2 = vim.fs.root(startpath, patterns2)

		if path1 and path2 then
			local path1_length = select(2, path1:gsub("/", ""))
			local path2_length = select(2, path2:gsub("/", ""))
			if path1_length > path2_length then
				on_dir(path1)
			end
		elseif path1 then
			on_dir(path1)
		end
	end
end

--- Whether the current working directory is a Deno project
---@return boolean
function M.is_deno_project()
	local deno_files = { "deno.json", "deno.jsonc", "deno.lock" }
	for _, filepath in ipairs(deno_files) do
		filepath = table.concat({ vim.fn.getcwd(), filepath }, "/")
		if vim.uv.fs_stat(filepath) ~= nil then
			return true
		end
	end
	return false
end

return M
