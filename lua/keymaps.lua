local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

-- Alt + vim keys for resizing windows
-- map("n", "<A-h>", "<C-w><", { noremap = true })
-- map("n", "<A-j>", "<C-w>-", { noremap = true })
-- map("n", "<A-k>", "<C-w>+", { noremap = true })
-- map("n", "<A-l>", "<C-w>>", { noremap = true })

-- nicer switch windows
vim.cmd([[
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
]])

vim.cmd([[
  " select everything
  nnoremap <C-A> ggVG

  " open new file adjacent to current file
  nnoremap <leader>o :e <C-R>=expand("%:p:h") . "/" <CR>

  " toggle between buffers current and prev buffer
  nnoremap <leader><leader> <c-^>
]])

-- or use leader+w instead
-- save by C-s
map("n", "<C-s>", ":w<cr>", default_opts)
map("i", "<C-s>", "<Esc>:w<cr>", default_opts)

-- map("n", "<Leader>", ":WhichKey<cr>", default_opts)

-- F1 ranger
-- F2
-- F3 lazygit
-- F4 search and replace
-- F5
-- F6 TODO comments
-- F7 toggle gitblame annotations

map("n", "Z", ":ZenMode<CR>", { noremap = true, silent = true })

-- switch buffers
map("n", "<A-d>", ":bp<CR>", { noremap = true, silent = true })
map("n", "<A-f>", ":bn<CR>", { noremap = true, silent = true })

-- *
-- Whichkey keys
-- *
--
local ws = require("which-key")

ws.register({ ["<Leader>h"] = { ":nohlsearch<CR>", "Clear Search" } })
ws.register({ ["<Leader>w"] = { ":w!<CR>", "Save" } })
ws.register({ ["<Leader>q"] = { ":q!<CR>", "Quit" } })

ws.register({
	name = "Git",
	j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
	k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
	L = { "<cmd>Git blame<cr>", "Blame All" },
	l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame line" },
	p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
	r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
	R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
	s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
	u = {
		"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
		"Undo Stage Hunk",
	},
	o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
	b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
	c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
	C = {
		"<cmd>Telescope git_bcommits<cr>",
		"Checkout commit(for current file)",
	},
	d = {
		"<cmd>Gitsigns diffthis HEAD<cr>",
		"Git Diff",
	},
}, {
	prefix = "<Leader>g",
})

ws.register({
	name = "Buffers",
	f = { "<cmd>Telescope buffers<cr>", "Find" },
	b = { "<cmd>b#<cr>", "Previous" },
	l = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
	r = {
		"<cmd>BufferLineCloseRight<cr>",
		"Close all to the right",
	},
	c = {
		"<cmd>bdelete!<CR>",
		"Close",
	},
	a = {
		"<cmd>%bd<CR>",
		"Close all",
	},
}, {
	prefix = "<Leader>b",
})

ws.register({
	name = "Code",
	a = { "<cmd>CodeActionMenu<cr>", "Code Action" },
	d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
	f = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format" },
	h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },
	e = { "<cmd>lua vim.lsp.buf.references({ includeDeclaration = false })<CR>", "Buf references" },
	f = {
		"<cmd>Telescope diagnostics bufnr=0<cr>",
		"Document Diagnostics",
	},
	w = {
		"<cmd>Telescope diagnostics<cr>",
		"Workspace Diagnostics",
	},
	j = {
		"<cmd>lua vim.diagnostic.goto_next()<cr>",
		"Next Diagnostic",
	},
	k = {
		"<cmd>lua vim.diagnostic.goto_prev()<cr>",
		"Prev Diagnostic",
	},
	-- r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" }, // by lspsaga in plugins
}, {
	prefix = "<Leader>c",
})

ws.register({
	name = "LSP",
	i = { "<cmd>LspInfo<cr>", "Info" },
	I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
}, {
	prefix = "<Leader>l",
})

-- 	l = {
-- 		name = "LSP",
-- 	},

-- which_key.mappings = {
-- 	["w"] = { "<cmd>w!<CR>", "Save" },
-- 	["q"] = { "<cmd>q!<CR>", "Quit" },
-- 	["/"] = { "test", "test" },
-- 	["f"] = { "<cmd>Telescope find_files<CR>", "Find File" },
-- 	["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
-- 	["c"] = { "<cmd>Close<CR>", "Close" },
--
-- 	-- " Available Debug Adapters:
-- 	-- "   https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/
-- 	-- " Adapter configuration and installation instructions:
-- 	-- "   https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
-- 	-- " Debug Adapter protocol:
-- 	-- "   https://microsoft.github.io/debug-adapter-protocol/
-- 	-- " Debugging
--
-- 	p = { "<cmd>Telescope projects<CR>", "Projects" },
-- 	s = {
-- 		name = "+Search",
-- 		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
-- 		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
-- 		f = { "<cmd>Telescope find_files<cr>", "Find File" },
-- 		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
-- 		M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
-- 		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
-- 		R = { "<cmd>Telescope registers<cr>", "Registers" },
-- 		t = { "<cmd>Telescope live_grep<cr>", "Text" },
-- 		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
-- 		C = { "<cmd>Telescope commands<cr>", "Commands" },
-- 		p = {
-- 			"<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
-- 			"Colorscheme with Preview",
-- 		},
-- 	},
-- 	C = {
-- 		name = "Code",
-- 		f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
-- 	},
-- 	L = {
-- 		name = "+LunarVim",
-- 		c = {
-- 			"<cmd>edit " .. get_config_dir() .. "/config.lua<cr>",
-- 			"Edit config.lua",
-- 		},
-- 		f = {
-- 			"<cmd>lua require('lvim.core.telescope.custom-finders').find_lunarvim_files()<cr>",
-- 			"Find LunarVim files",
-- 		},
-- 		g = {
-- 			"<cmd>lua require('lvim.core.telescope.custom-finders').grep_lunarvim_files()<cr>",
-- 			"Grep LunarVim files",
-- 		},
-- 		k = { "<cmd>Telescope keymaps<cr>", "View LunarVim's keymappings" },
-- 		i = {
-- 			"<cmd>lua require('lvim.core.info').toggle_popup(vim.bo.filetype)<cr>",
-- 			"Toggle LunarVim Info",
-- 		},
-- 		I = {
-- 			"<cmd>lua require('lvim.core.telescope.custom-finders').view_lunarvim_changelog()<cr>",
-- 			"View LunarVim's changelog",
-- 		},
-- 		l = {
-- 			name = "+logs",
-- 			d = {
-- 				"<cmd>lua require('lvim.core.terminal').toggle_log_view(require('lvim.core.log').get_path())<cr>",
-- 				"view default log",
-- 			},
-- 			D = {
-- 				"<cmd>lua vim.fn.execute('edit ' .. require('lvim.core.log').get_path())<cr>",
-- 				"Open the default logfile",
-- 			},
-- 			l = {
-- 				"<cmd>lua require('lvim.core.terminal').toggle_log_view(vim.lsp.get_log_path())<cr>",
-- 				"view lsp log",
-- 			},
-- 			L = { "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>", "Open the LSP logfile" },
-- 			n = {
-- 				"<cmd>lua require('lvim.core.terminal').toggle_log_view(os.getenv('NVIM_LOG_FILE'))<cr>",
-- 				"view neovim log",
-- 			},
-- 			N = { "<cmd>edit $NVIM_LOG_FILE<cr>", "Open the Neovim logfile" },
-- 			p = {
-- 				"<cmd>lua require('lvim.core.terminal').toggle_log_view('packer.nvim')<cr>",
-- 				"view packer log",
-- 			},
-- 			P = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<cr>", "Open the Packer logfile" },
-- 		},
-- 		r = { "<cmd>LvimReload<cr>", "Reload LunarVim's configuration" },
-- 		u = { "<cmd>LvimUpdate<cr>", "Update LunarVim" },
-- 	},
-- 	P = {
-- 		name = "Packer",
-- 		c = { "<cmd>PackerCompile<cr>", "Compile" },
-- 		i = { "<cmd>PackerInstall<cr>", "Install" },
-- 		r = { "<cmd>lua require('lvim.plugin-loader').recompile()<cr>", "Re-compile" },
-- 		s = { "<cmd>PackerSync<cr>", "Sync" },
-- 		S = { "<cmd>PackerStatus<cr>", "Status" },
-- 		u = { "<cmd>PackerUpdate<cr>", "Update" },
-- 	},
-- 	T = {
-- 		name = "Treesitter",
-- 		i = { ":TSConfigInfo<cr>", "Info" },
-- 	},
-- }
--
