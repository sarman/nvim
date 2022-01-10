-- autocommands

function nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		vim.api.nvim_command("augroup " .. group_name)
		vim.api.nvim_command("autocmd!")
		for _, def in ipairs(definition) do
			-- if type(def) == 'table' and type(def[#def]) == 'function' then
			-- 	def[#def] = lua_callback(def[#def])
			-- end
			local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
			vim.api.nvim_command(command)
		end
		vim.api.nvim_command("augroup END")
	end
end

local autocmds = {
	formatters = {
		{ "BufWinEnter", "*.lua", "setlocal ts=2 sw=2 expandtab" },
		{
			"BufWinEnter",
			"*.php,*.svelte,*.js,*.ts,*.json,*.yaml,*.html",
			"set autoindent",
		},

		-- On entering insert mode in any file, scroll the window so the cursor line is centered
		--		{ "InsertEnter", "*", ":normal zz" },
		--		{ "BufEnter,FocusGained,InsertLeave,WinEnter", "*", 'if &nu && mode() != "i" | set rnu | endif' },
		--		{ "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "if &nu | set nornu | endif" },
		{
			-- "TextChanged,InsertLeave",
			"BufWrite",
			"*.js,*.jsx,*.ts,*.css,*.less,*.scss,*.json,*.vue,*.yaml,*.html,*.yml,*.yaml",
			"PrettierAsync",
		},
		{
			-- "TextChanged,InsertLeave",
			"BufWrite",
			"*.svelte",
			":lua vim.lsp.buf.formatting()",
		},
		{ "BufWritePre", "*.lua", ":lua require('stylua-nvim').format_file()" },
		-- { "BufWritePre", "*.php", ":PhpCsFixerFixFile()" },
	},
}

nvim_create_augroups(autocmds)
