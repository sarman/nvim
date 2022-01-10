vim.cmd([[packadd packer.nvim]])

vim.cmd([[
  augroup RecompilePlugins
    autocmd! BufWritePost plugins.lua let g:plugins_recompile=1 | source <afile> | PackerCompile
  augroup END
]])

map = vim.api.nvim_set_keymap
default_opts = { noremap = true, silent = true }

local function setup_packer(packer_bootstrap)
	require("packer").startup(function(use)
		use("wbthomason/packer.nvim")

		-- Improve Start-UP time
		use({ -- Speed up loading Lua modules in Neovim to improve startup time.
			"lewis6991/impatient.nvim",
		})

		use({ --  Easily speed up your neovim startup time!. A faster version of filetype.vim
			"nathom/filetype.nvim",
		})

		-- Use the command :StartupTime to get an averaged startup
		-- profile. By default, it collects 10 samples.
		-- use({ "tweekmonster/startuptime.vim", cmd = "StartupTime" })

		-- a universal set of defaults
		use("tpope/vim-sensible")

		-- All schemes
		-- use("flazz/vim-colorschemes")

		use({
			"doums/darcula",
			config = function()
				vim.cmd("colorscheme darcula")

				-- LSP diag custom color
				vim.cmd([[
      hi DiagnosticError guifg=#454545
      hi DiagnosticWarn  guifg=#4a442e
      hi DiagnosticInfo  guifg=#30374a
      hi DiagnosticHint  guifg=#3c4d41
      hi TabLineFill ctermfg=LightGreen ctermbg=DarkGreen
      hi TabLineSel ctermfg=Red ctermbg=Yellow
      ]])
			end,
		})

		vim.o.background = "dark"

		-- vim.cmd("colorscheme clearance")
		-- vim.cmd([[hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white]])

		-- Telescope
		use({
			"nvim-telescope/telescope.nvim",
			requires = {
				"nvim-lua/popup.nvim",
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope-live-grep-raw.nvim",
			},
			config = function()
				local vimgrep_args_hidden_files = require("telescope.config").set_defaults().get("vimgrep_arguments")
				table.insert(vimgrep_args_hidden_files, "--hidden")

				require("which-key").register({
					name = "Telescope",
					f = { "<cmd>Telescope find_files hidden=true<CR>", "Files" },
					G = {
						name = "Git",
						s = { "<cmd>Telescope git_status<CR>", "Status" },
						f = { "<cmd>Telescope git_files<CR>", "Files" },
						b = { "<cmd>Telescope git_branches<CR>", "Branches" },
					},
					b = { "<cmd>Telescope buffers<CR>", "Buffers" },
					h = { "<cmd>Telescope help_tags<CR>", "Help tags" },
					t = { "<cmd>Telescope treesitter<CR>", "Treesitter" },
					g = { "<cmd>Telescope live_grep<CR>", "Live grep" },
					o = { "<cmd>Telescope oldfiles<CR>", "Old files" },
					r = { "<cmd>Telescope lsp_references<CR>", "LSP references" },
					s = { "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "LSP workspace symbols" },
					a = { "<cmd>Telescope lsp_code_actions<CR>", "LSP code actions" },
					p = {
						"<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
						"Colorscheme with Preview",
					},
				}, {
					prefix = "<Leader>f",
				})

				require("telescope").setup({
					defaults = {
						file_ignore_patterns = { ".git/.*", "vendor/.*", "composer/.*" },
						path_display = { ["truncate"] = 2 },
						vimgrep_arguments = {
							"rg",
							"--color=never",
							"--no-heading",
							"--with-filename",
							"--line-number",
							"--column",
							"--smart-case",
						},

						file_sorter = require("telescope.sorters").get_fuzzy_file,
						generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
						file_previewer = require("telescope.previewers").vim_buffer_cat.new,
						grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
						qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

						prompt_prefix = "🔎︎ ",
						selection_caret = "➤ ",
						entry_prefix = "  ",
						winblend = 0,
						border = {},
						borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
						color_devicons = true,
						use_less = true,
						set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
						path_display = { "absolute" }, -- How file paths are displayed ()

						-- Developer configurations: Not meant for general override
						buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
						initial_mode = "insert",
						selection_strategy = "reset",
						sorting_strategy = "ascending",
						layout_strategy = "horizontal",
						layout_config = {
							horizontal = {
								mirror = false,
								prompt_position = "top",
							},
							vertical = {
								mirror = false,
							},
						},
					},
					extensions = {},
				})
			end,
		})

		-- Clipboard manager
		use({
			"AckslD/nvim-neoclip.lua",
			config = function()
				require("neoclip").setup()
				require("which-key").register({
					name = "Telescope",
					c = { ":Telescope neoclip<CR>", "Clipboard Manager" },
				}, {
					prefix = "<Leader>f",
				})
				require("telescope").load_extension("neoclip")
			end,
		})

		-- Insert or delete brackets, parens, quotes in pair.
		use({
			"windwp/nvim-autopairs",
			config = function()
				local autopairs = require("nvim-autopairs")
				autopairs.setup({
					disable_filetype = { "TelescopePrompt" },
					disable_in_macro = false, -- disable when recording or executing a macro
					disable_in_visualblock = false, -- disable when insert after visual block mode
					ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
					enable_moveright = true,
					enable_afterquote = true, -- add bracket pairs after quote
					enable_check_bracket_line = true, --- check bracket in same line
					check_ts = false,
					map_bs = true, -- map the <BS> key
					map_c_h = false, -- Map the <C-h> key to delete a pair
					map_c_w = false, -- map <c-w> to delete a pair if possible
					fast_wrap = {
						-- Before        Input                    After
						--------------------------------------------------
						-- (|foobar      <M-e> then press $        (|foobar)
						-- (|)(foobar)   <M-e> then press q       (|(foobar))
						map = "<A-e>",
						chars = { "{", "[", "(", '"', "'" },
						pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
						offset = 0, -- Offset from pattern match
						end_key = "$",
						keys = "qwertyuiopzxcvbnmasdfghjkl",
						check_comma = true,
						highlight = "Search",
						highlight_grey = "Comment",
					},
				})
			end,
		})

		-- Counter search
		use("google/vim-searchindex")

		-- more smart .
		use("tpope/vim-repeat")

		-- more pairs objects
		-- To change the text in the next pair of parentheses, use the cin) command
		-- cursor position │    .....................
		-- buffer line     │    This is example text (with a pair of parentheses).
		-- selection       │                          └───────── cin) ─────────┘
		-- To delete the item in a comma separated list under the cursor, use da,

		-- cursor position │                                  .........
		-- buffer line     │    Shopping list: oranges, apples, bananas, tomatoes
		-- selection       │                                  └─ da, ─┘
		-- more in docs!!!
		use("wellle/targets.vim")

		-- Svelte framework support
		use({ "evanleck/vim-svelte" })

		use({ -- help you get to any word on a line in two or three keystrokes with Vim's built-in f<char>
			-- (which moves your cursor to <char>).  ; and , are forward and backward
			"unblevable/quick-scope",
			config = function()
				vim.cmd([[
      let g:qs_highlight_on_keys = ['f']
      ]])
			end,
		})

		-- Z key Zen mode
		use({
			"folke/zen-mode.nvim",
			config = function()
				require("zen-mode").setup({
					window = {
						backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
						-- height and width can be:
						-- * an absolute number of cells when > 1
						-- * a percentage of the width / height of the editor when <= 1
						-- * a function that returns the width or the height
						width = 120, -- width of the Zen window
						height = 1, -- height of the Zen window
						-- by default, no options are changed for the Zen window
						-- uncomment any of the options below, or add other vim.wo options you want to apply
						options = {
							signcolumn = "no", -- disable signcolumn
							-- number = false, -- disable number column
							-- relativenumber = false, -- disable relative numbers
							-- cursorline = false, -- disable cursorline
							cursorcolumn = false, -- disable cursor column
							-- foldcolumn = "0", -- disable fold column
							-- list = false, -- disable whitespace characters
						},
					},
					plugins = {
						-- disable some global vim options (vim.o...)
						-- comment the lines to not apply the options
						options = {
							enabled = true,
							ruler = false, -- disables the ruler text in the cmd line area
							showcmd = false, -- disables the command in the last line of the screen
						},
						twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
						gitsigns = { enabled = false }, -- disables git signs
						tmux = { enabled = false }, -- disables the tmux statusline
						-- this will change the font size on kitty when in zen mode
						-- to make this work, you need to set the following kitty options:
						-- - allow_remote_control socket-only
						-- - listen_on unix:/tmp/kitty
						kitty = {
							enabled = true,
							font = "+4", -- font size increment
						},
					},
					-- callback where you can add custom code when the Zen window opens
					on_open = function(win) end,
					-- callback where you can add custom code when the Zen window closes
					on_close = function() end,
				})
				map("n", "Z", ":ZenMode<CR>", { noremap = true, silent = true })
			end,
		})

		-- dim inactive code, best for pair with Zen mode
		use({
			"folke/twilight.nvim",
			config = function()
				require("twilight").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					dimming = {
						alpha = 0.35, -- amount of dimming
						-- we try to get the foreground from the highlight groups or fallback color
						color = { "Normal", "#ffffff" },
						inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
					},
					context = 10, -- amount of lines we will try to show around the current line
					treesitter = true, -- use treesitter when available for the filetype
					-- treesitter is used to automatically expand the visible text,
					-- but you can further control the types of nodes that should always be fully expanded
					expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
						"function",
						"method",
						"table",
						"if_statement",
					},
					exclude = {}, -- exclude these filetypes
				})
			end,
		})

		use({ -- jumper leader+j
			"phaazon/hop.nvim",
			config = function()
				require("hop").setup()
				require("which-key").register({ ["<Leader>j"] = { ":HopWord<CR>", "HopWord" } })
			end,
		})

		-- ]q is :cnext. [q is :cprevious. ]a is :next.
		-- [b is :bprevious. See the documentation for the full
		-- set of 20 mappings and mnemonics. All of them take a count.
		use({
			"tpope/vim-unimpaired",
		})

		-- git show diffs more
		use({
			"rickhowe/diffchar.vim",
			after = "vim-unimpaired",
		})

		-- ranger file manager
		use({
			"kevinhwang91/rnvimr",
			config = function()
				vim.g.rnvimr_draw_border = 1
				vim.g.rnvimr_pick_enable = 1
				vim.g.rnvimr_bw_enable = 1
				vim.api.nvim_set_keymap("n", "<F1>", ":RnvimrToggle<CR>", { noremap = true, silent = true })
			end,
		})

		use({
			"kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-web-devicons").setup({
					default = true,
				})
			end,
		})

		-- use({
		-- 	"kyazdani42/nvim-tree.lua",
		-- 	requires = "kyazdani42/nvim-web-devicons",
		-- 	config = function()
		-- 		vim.g.nvim_tree_git_hl = 1
		-- 		vim.g.nvim_tree_group_empty = 1

		-- 		require("nvim-tree").setup({
		-- 			update_focused_file = {
		-- 				enable = true,
		-- 			},
		-- 			diagnostics = {
		-- 				enable = true,
		-- 			},
		-- 			git = {
		-- 				ignore = true,
		-- 			},
		-- 		})
		-- 		require("which-key").register({
		-- 			name = "Navigation",
		-- 			n = { ":NvimTreeToggle<CR>", "Toggle NvimTree" },
		-- 			r = { ":NvimTreeFindFile<CR>", "Find file in NvimTree" },
		-- 			f = { ":NvimTreeFocus<CR>", "Focus NvimTree" },
		-- 			t = { ":TagbarToggle<CR>", "Toggle Tagbar" },
		-- 		}, {
		-- 			prefix = "<Leader>n",
		-- 		})
		-- 	end,
		-- })

		use({
			"nvim-lualine/lualine.nvim",
			requires = { "kyazdani42/nvim-web-devicons", opt = true },
			config = function()
				local dap_extension = {
					sections = {
						lualine_a = { "mode", "filename" },
					},
					inactive_sections = {
						lualine_a = { "filename" },
					},
					filetypes = {
						"dapui_scopes",
						"dapui_watches",
						"dapui_stacks",
						"dapui_breakpoints",
						"dap-repl",
					},
				}

				require("lualine").setup({
					options = {
						icons_enabled = true,
						theme = "gruvbox_dark",
						component_separators = { left = "", right = "" },
						section_separators = { left = "", right = "" },
						disabled_filetypes = {},
						always_divide_middle = true,
					},
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "branch" },
						lualine_c = {
							{
								"filename",
								path = 1, -- NOTE: show relative file path
							},
						},
						lualine_x = {
							{
								"diagnostics",
								sources = { "nvim_diagnostic" },
								diagnostics_color = {
									error = "VirtualTextError",
									warn = "VirtualTextWarn",
									info = "VirtualTextInfo",
									hint = "VirtualTextHint",
								},
							},
							"encoding",
							"fileformat",
							"filetype",
						},
						lualine_y = { "progress" },
						lualine_z = { "location" },
					},
					extensions = { "fugitive", "quickfix", "fzf", "toggleterm", "symbols-outline" },
				})
			end,
		})

		-- tab bar
		use({
			"akinsho/bufferline.nvim",
			config = function()
				require("bufferline").setup({
					options = {
						numbers = "ordinal",
						close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
						right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
						left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
						middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
						-- NOTE: this plugin is designed with this icon in mind,
						-- and so changing this is NOT recommended, this is intended
						-- as an escape hatch for people who cannot bear it for whatever reason
						indicator_icon = "▎",
						buffer_close_icon = "",
						modified_icon = "●",
						close_icon = "",
						left_trunc_marker = "",
						right_trunc_marker = "",
						--- name_formatter can be used to change the buffer's label in the bufferline.
						--- Please note some names can/will break the
						--- bufferline so use this at your discretion knowing that it has
						--- some limitations that will *NOT* be fixed.
						name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
							-- remove extension from markdown files for example
							if buf.name:match("%.md") then
								return vim.fn.fnamemodify(buf.name, ":t:r")
							end
						end,
						max_name_length = 18,
						max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
						tab_size = 18,
						-- diagnostics = "nvim_lsp",
						-- diagnostics_update_in_insert = false,
						show_buffer_icons = false, -- disable filetype icons for buffers
						show_buffer_close_icons = true,
						show_close_icon = true,
						show_tab_indicators = true,
						persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
						-- can also be a table containing 2 custom separators
						-- [focused and unfocused]. eg: { '|', '|' }
						-- "slant" | "thick" | "thin"
						separator_style = "thick",
						enforce_regular_tabs = true,
						always_show_bufferline = true,
						sort_by = "id",
					},
				})
			end,
			requires = "kyazdani42/nvim-web-devicons",
		})

		-- git wrap commands
		use("tpope/vim-fugitive")

		use({
			"glepnir/dashboard-nvim",
			config = function()
				-- Default value is clap
				vim.g.dashboard_default_executive = "telescope"

				vim.g.dashboard_custom_header = {
					"-= Sarman neovim =-",
				}

				local utils = require("telescope.utils")
				vim.g.dashboard_custom_footer = utils.get_os_command_output({ "fortune", "ru" })

				vim.g.dashboard_custom_section = {
					a = {
						description = { "  Projects        " },
						command = "Telescope projects",
					},
					b = {
						description = { "  Restore Session" },
						command = "lua require('persistence').load({ last = true })",
					},
					c = {
						description = { "  Update plugins " },
						command = "PackerSync",
					},
					d = {
						description = { "  Files          " },
						command = "Telescope find_files hidden=true",
					},
					e = {
						description = { "  Find Text      " },
						command = "Telescope live_grep",
					},
					f = { description = { "  Recent Files   " }, command = "Telescope oldfiles" },
					g = { description = { "  New File       " }, command = "enew" },
					h = {
						description = { "  Settings       " },
						command = "e ~/.config/nvim/init.lua",
					},
					k = {
						description = { "  Plugins        " },
						command = "e ~/.config/nvim/lua/plugins.lua",
					},
				}
				require("which-key").register({ ["<Leader>p"] = { ":Telescope projects<CR>", "Projects" } })
				require("telescope").load_extension("projects")
			end,
		})

		-- Lua
		use({
			"ahmedkhalf/project.nvim",
			config = function()
				vim.g.nvim_tree_respect_buf_cwd = 1

				require("project_nvim").setup({
					-- Manual mode doesn't automatically change your root directory, so you have
					-- the option to manually do so using `:ProjectRoot` command.
					manual_mode = false,

					-- Methods of detecting the root directory. **"lsp"** uses the native neovim
					-- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
					-- order matters: if one is not detected, the other is used as fallback. You
					-- can also delete or rearangne the detection methods.
					detection_methods = { "lsp", "pattern" },

					-- All the patterns used to detect root dir, when **"pattern"** is in
					-- detection_methods
					patterns = { ".git" },

					-- Table of lsp clients to ignore by name
					-- eg: { "efm", ... }
					ignore_lsp = {},

					-- Don't calculate root dir on specific directories
					-- Ex: { "~/.cargo/*", ... }
					exclude_dirs = {},

					-- Show hidden files in telescope
					show_hidden = true,

					-- When set to false, you will get a message when project.nvim changes your
					-- directory.
					silent_chdir = true,

					-- Path where project.nvim will store the project history for use in
					-- telescope
					datapath = vim.fn.stdpath("data"),
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})

		use({ -- jump to lines when type them as command :1234 etc
			"nacro90/numb.nvim",
			event = "BufRead",
			config = function()
				require("numb").setup({
					show_numbers = true, -- Enable 'number' for the window while peeking
					show_cursorline = true, -- Enable 'cursorline' for the window while peeking
				})
			end,
		})

		use({ -- autocompletion AI
			"tzachar/cmp-tabnine",
			config = function()
				local tabnine = require("cmp_tabnine.config")
				tabnine:setup({
					max_lines = 1000,
					max_num_results = 20,
					sort = true,
				})
			end,

			run = "./install.sh",
			requires = "hrsh7th/nvim-cmp",
		})

		use({ -- flutter
			"akinsho/flutter-tools.nvim",
			requires = "nvim-lua/plenary.nvim",
			config = function()
				require("user.flutter_tools").config()
			end,
			ft = "dart",
		})

		-- use({ -- highlight words by word under cursor
		-- 	"yamatsum/nvim-cursorline",
		-- 	opt = true,
		-- 	event = "BufWinEnter",
		-- 	disable = false,
		-- })

		-- tree undo
		use({
			"mbbill/undotree",
			config = function()
				vim.o.undofile = true
				require("which-key").register({ ["<Leader>u"] = { ":UndotreeToggle<CR>", "Toggle undo tree" } })
			end,
		})

		-- Visual keys
		use({
			"folke/which-key.nvim",
			config = function()
				require("which-key").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
					marks = true, -- shows a list of your marks on ' and `
					registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
					spelling = {
						enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
						suggestions = 20, -- how many suggestions should be shown in the list?
					},
					presets = {
						operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
						motions = true, -- adds help for motions
						text_objects = true, -- help for text objects triggered after entering an operator
						windows = true, -- default bindings on <c-w>
						nav = true, -- misc bindings to work with windows
						z = true, -- bindings for folds, spelling and others prefixed with z
						g = true, -- bindings for prefixed with g
					},
					triggers = "auto", -- automatically setup triggers
					-- triggers = { "<leader>" }, -- or specify a list manually
					ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
				})
			end,
		})

		-- comment block by gc, line gcc, maybe change to
		use({
			"tpope/vim-commentary",
			config = function()
				local ws = require("which-key")
				ws.register({
					name = "Code",
					c = {
						"<cmd>Commentary<cr>",
						"Comment",
					},
				}, {
					prefix = "<Leader>c",
				})
			end,
		})

		-- The goal of nvim-bqf is to make Neovim's quickfix window better.
		-- fzf is optional
		use({ "kevinhwang91/nvim-bqf", ft = "qf" })
		-- fast search, require for many plugins
		use({
			"junegunn/fzf",
			run = function()
				vim.fn["fzf#install"]()
				vim.cmd([[
        let $FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow --g '!{.git,node_modules}'"
        ]])
			end,
		})

		-- vertical indent lines
		-- use({
		-- 	"lukas-reineke/indent-blankline.nvim",
		-- 	config = function()
		-- 		-- vim.cmd([[highlight VertSplit guifg=#404040 gui=nocombine]])
		-- 		require("indent_blankline").setup({
		-- 			use_treesitter = true,
		-- 			show_current_context = true,
		-- 			show_current_context_start = true,
		-- 			context_highlight_list = { "Blue" },
		-- 			context_patterns = {
		-- 				"class",
		-- 				"function$",
		-- 				"declaration$",
		-- 				"^import",
		-- 				"method",
		-- 				"if_statement",
		-- 				"else_clause",
		-- 				"jsx_element",
		-- 				"jsx_self_closing_element",
		-- 				"try_statement",
		-- 				"catch_clause",
		-- 				"object",
		-- 				"return_statement",
		-- 				"formal_parameters",
		-- 				"^for",
		-- 				"^while",
		-- 				"arguments",
		-- 				"table", -- Lua tables
		-- 			},

		-- 			filetype_exclude = { "help" },
		-- 			buftype_exclude = { "terminal" },
		-- 			bufname_exclude = { "" }, -- Disables the plugin in hover() popups and new files

		-- 			char_highlight_list = { "VertSplit" },

		-- 			-- NOTE: alternating indentation highlight
		-- 			-- space_char_highlight_list = { "MsgSeparator", "Normal" },
		-- 			show_trailing_blankline_indent = false,
		-- 		})
		-- 	end,
		-- 	requires = "nvim-treesitter/nvim-treesitter",
		-- })

		-- Colorize #ffffff
		use({
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup()
			end,
		})

		-- git signs on the left
		use({
			"lewis6991/gitsigns.nvim",
			requires = {
				"nvim-lua/plenary.nvim",
			},
			config = function()
				require("gitsigns").setup()
			end,
		})

		-- nice commands popup
		use({
			"gelguy/wilder.nvim",
			config = function()
				-- Use a vimscript file because of a bug with using line continuations
				-- See https://github.com/gelguy/wilder.nvim/issues/53
				-- TODO: use <sfile>
				vim.cmd([[source $HOME/.config/nvim/wilder.vim]])

				vim.cmd([[call wilder#main#start()]])
			end,
			run = ":UpdateRemotePlugins",
			event = "CmdlineEnter",
		})

		use({ "matze/vim-move" }) -- move selection up or down by Alt-hjkl

		use({
			"kdheepak/lazygit.nvim",
			config = function()
				map("n", "<F3>", ":LazyGit<CR>", { noremap = true, silent = true })
			end,
		})

		-- prettier integration
		use({ "prettier/vim-prettier" })

		-- LSP
		use({
			"neovim/nvim-lspconfig",
			config = function()
				vim.o.cmdheight = 2
				vim.opt.shortmess:append("c")
				-- require("lsp")
			end,
			requires = {
				"jose-elias-alvarez/nvim-lsp-ts-utils",
				"jose-elias-alvarez/null-ls.nvim",
				"b0o/SchemaStore.nvim",
				"williamboman/nvim-lsp-installer", -- :LspInstall lang
			},
		})

		use({
			"glepnir/lspsaga.nvim",
			config = function()
				local saga = require("lspsaga")
				saga.init_lsp_saga({
					code_action_prompt = { enable = false },
					finder_action_keys = {
						open = "o",
						vsplit = "s",
						split = "i",
						quit = "q",
						scroll_down = "<C-f>",
						scroll_up = "<C-b>", -- quit can be a table
					},
					code_action_keys = {
						quit = "q",
						exec = "<CR>",
					},
					rename_action_keys = {
						quit = "<C-c>",
						exec = "<CR>", -- quit can be a table
					},
				})
			end,
		})

		local null_ls = require("null-ls")

		-- register any number of sources simultaneously
		local sources = {
			null_ls.builtins.formatting.prettier,
			null_ls.builtins.diagnostics.write_good,
			null_ls.builtins.code_actions.gitsigns,
		}
		null_ls.setup({ sources = sources })

		use({
			"nvim-lua/lsp_extensions.nvim",
			config = function()
				local inlay_hints_options = {
					prefix = "",
					highlight = "Comment",
					enabled = { "TypeHint", "ChainingHint", "ParameterHint" },
				}
				vim.cmd("augroup LspExtensions")
				vim.cmd("autocmd!")
				vim.cmd(
					[[autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints ]]
						.. vim.inspect(inlay_hints_options, { newline = "" })
				)
				vim.cmd("augroup END")
			end,
		})

		-- sudo npm i intelephense -g
		local lsp_installer = require("nvim-lsp-installer")

		lsp_installer.on_server_ready(function(server)
			local opts = {}

			-- (optional) Customize the options passed to the server
			-- if server.name == "tsserver" then
			--     opts.root_dir = function() ... end
			-- end

			-- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
			server:setup(opts)
			vim.cmd([[ do User LspAttachBuffers ]])
		end)
		local on_attach = function(client, bufnr)
			require("lsp_signature").on_attach({
				bind = true,
				handler_opts = {
					border = "single",
				},
			})
		end

		-- require'lspconfig'.phpactor.setup {
		-- cmd = {'~/.cache/composer/files/phpactor', 'language-server'}
		--}

		-- local nvim_lsp = require("lspconfig")
		-- nvim_lsp.intelephense.setup({
		-- 	settings = {
		-- 		intelephense = {
		-- 			format = {
		-- 				enable = true,
		-- 			},
		-- 			--      diagnostics = {
		-- 			--  undefinedClassConstants= false,
		-- 			--  undefinedConstants= false,
		-- 			--  undefinedFunctions= false,
		-- 			--  undefinedMethods= false,
		-- 			--  undefinedProperties= false,
		-- 			--  undefinedTypes= false,
		-- 			-- },
		-- 			stubs = {
		-- 				"bcmath",
		-- 				"bz2",
		-- 				"calendar",
		-- 				"Core",
		-- 				"curl",
		-- 				"date",
		-- 				"dba",
		-- 				"dom",
		-- 				"enchant",
		-- 				"fileinfo",
		-- 				"filter",
		-- 				"ftp",
		-- 				"gd",
		-- 				"gettext",
		-- 				"hash",
		-- 				"iconv",
		-- 				"imap",
		-- 				"intl",
		-- 				"json",
		-- 				"ldap",
		-- 				"libxml",
		-- 				"mbstring",
		-- 				"mcrypt",
		-- 				"mysql",
		-- 				"mysqli",
		-- 				"password",
		-- 				"pcntl",
		-- 				"pcre",
		-- 				"PDO",
		-- 				"pdo_mysql",
		-- 				"Phar",
		-- 				"readline",
		-- 				"recode",
		-- 				"Reflection",
		-- 				"regex",
		-- 				"session",
		-- 				"SimpleXML",
		-- 				"soap",
		-- 				"sockets",
		-- 				"sodium",
		-- 				"SPL",
		-- 				"standard",
		-- 				"superglobals",
		-- 				"sysvsem",
		-- 				"sysvshm",
		-- 				"tokenizer",
		-- 				"xml",
		-- 				"xdebug",
		-- 				"xmlreader",
		-- 				"xmlwriter",
		-- 				"yaml",
		-- 				"zip",
		-- 				"zlib",
		-- 				"wordpress",
		-- 				"woocommerce",
		-- 				"acf-pro",
		-- 				"wordpress-globals",
		-- 				"wp-cli",
		-- 				"genesis",
		-- 				"polylang",
		-- 			},
		-- 			files = {
		-- 				maxSize = 5000000,
		-- 			},
		-- 		},
		-- 	},
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- })

		-- use({
		-- 	"stephpy/vim-php-cs-fixer",
		-- 	config = function()
		-- 		vim.g.php_cs_fixer_rules = "@PSR2" -- options: --rules (default:@PSR2)
		-- 		vim.g.php_cs_fixer_cache = ".php_cs.cache" -- options: --cache-file
		-- 		vim.g.php_cs_fixer_config_file = ".php_cs" -- options: --config
		--
		-- 		vim.g.php_cs_fixer_php_path = "php" -- Path to PHP
		-- 		vim.g.php_cs_fixer_enable_default_mapping = 1 -- Enable the mapping by default (<leader>pcd)
		-- 		vim.g.php_cs_fixer_dry_run = 0 -- Call command with dry-run option
		-- 		vim.g.php_cs_fixer_verbose = 0 -- Return the output of command if 1, else an inline information.
		-- 	end,
		-- })

		-- autocomplete engine
		use({
			"hrsh7th/nvim-cmp",
			config = function()
				vim.opt.completeopt = { "menuone", "noselect" }

				vim.cmd([[
		let g:vsnip_snippet_dir = expand("~/.config/nvim/snippets/")
		let b:vsnip_snippet_dir = expand("~/.config/nvim/snippets/")
		]])

				local function prepare_sources()
					-- NOTE: order matters. The order will be maintained in completions popup
					local sources = {
						{ name = "nvim_lsp", label = "LSP" },
						{ name = "crates", label = "crates.nvim" },
						{ name = "npm" },
						{ name = "vsnip" },
						{ name = "nvim_lua" },
						{ name = "path" },
						{ name = "buffer", keyword_length = 4 },
						{ name = "tmux", keyword_length = 4 },
						{ name = "calc" },
						{ name = "emoji" },
					}

					local source_labels = {}

					for _, source in ipairs(sources) do
						source_labels[source.name] = string.format("[%s]", source.label or source.name)
					end

					return sources, source_labels
				end

				local sources, source_labels = prepare_sources()

				local cmp = require("cmp")
				cmp.setup({
					snippet = {
						expand = function(args)
							vim.fn["vsnip#anonymous"](args.body)
						end,
					},
					mapping = {
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-y>"] = cmp.mapping.close(),
						["<C-u>"] = cmp.mapping.scroll_docs(4),
						["<C-d>"] = cmp.mapping.scroll_docs(-4),
						["<CR>"] = cmp.mapping.confirm({ select = false }),
					},
					sources = sources,
					formatting = {
						format = require("lspkind").cmp_format({ with_text = true, menu = source_labels }),
					},
				})

				-- https://github.com/hrsh7th/vim-vsnip#2-setting
				vim.cmd([[
		imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
		smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
		imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
		smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
		]])
				vim.g.vsnip_filetypes = {
					svelte = { "typescript", "javascript", "svelte", "svelte-script", "svelte-style" },
				}
			end,
			requires = {
				"hrsh7th/vim-vsnip",
				"hrsh7th/vim-vsnip-integ",
				"Neevash/awesome-flutter-snippets",
				"hrsh7th/cmp-vsnip",
				"hrsh7th/cmp-buffer",
				"Saecki/crates.nvim",
				"hrsh7th/cmp-path",
				"andersevenrud/cmp-tmux",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-calc",
				"hrsh7th/cmp-nvim-lsp",
				"rafamadriz/friendly-snippets",
				"hrsh7th/cmp-emoji",
				"onsails/lspkind-nvim",
			},
		})

		-- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help
		-- you solve all the trouble your code is causing.
		use({
			"folke/trouble.nvim",
			config = function()
				local ws = require("which-key")
				ws.register({
					name = "Trouble",
					x = { "<cmd>TroubleToggle<CR>", "Toggle" },
					w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<CR>", "Workspace diagnostics" },
					d = { "<cmd>TroubleToggle document_diagnostics<CR>", "Document diagnostics" },
					q = { "<cmd>TroubleToggle quickfix<CR>", "Quickfix" },
				}, {
					prefix = "<Leader>t",
				})
				ws.register({
					["gR"] = { "<cmd>TroubleToggle lsp_references<CR>", "Trouble LSP references" },
				})
			end,
		})

		-- highlight function params
		use({
			"ray-x/lsp_signature.nvim",
			config = function()
				-- vim.cmd([[highlight! link LspSignatureActiveParameter WildMenu]])
				require("lsp_signature").setup({
					debug = false, -- set to true to enable debug logging
					log_path = "debug_log_file_path", -- debug log path
					verbose = false, -- show debug line number

					bind = true, -- This is mandatory, otherwise border config won't get registered.
					-- If you want to hook lspsaga or other signature handler, pls set to false
					doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
					-- set to 0 if you DO NOT want any API comments be shown
					-- This setting only take effect in insert mode, it does not affect signature help in normal
					-- mode, 10 by default

					floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

					floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
					-- will set to true when fully tested, set to false will use whichever side has more space
					-- this setting will be helpful if you do not want the PUM and floating win overlap
					fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
					hint_enable = true, -- virtual hint enable
					hint_prefix = "🐼 ", -- Panda for parameter
					hint_scheme = "String",
					use_lspsaga = false, -- set to true if you want to use lspsaga popup
					hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
					max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
					-- to view the hiding contents
					max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
					handler_opts = {
						border = "rounded", -- double, rounded, single, shadow, none
					},

					always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

					auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
					extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
					zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

					padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc

					transparency = nil, -- disabled by default, allow floating win transparent value 1~100
					shadow_blend = 36, -- if you using shadow as border use this set the opacity
					shadow_guibg = "Black", -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
					timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
					toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
				}) -- no need to specify bufnr if you don't use toggle_key

				-- You can also do this inside lsp on_attach
				-- note: on_attach deprecated
				-- require("lsp_signature").on_attach(cfg, bufnr) -- no need to specify bufnr if you don't use toggle_key
				-- require("lsp_signature").status_line(max_width)
			end,
		})

		-- This tiny plugin adds vscode-like pictograms to neovim built-in lsp autocomplete popups
		use({
			"onsails/lspkind-nvim",
			config = function()
				require("lspkind").init()
			end,
		})

		-- This plugin provides a handy pop-up menu for code actions.
		-- I run it on leader+l+a
		-- alternative is telescope lsp actions leader+f+a
		use({
			"weilbith/nvim-code-action-menu",
			cmd = "CodeActionMenu",
		})

		-- Treesitter (need to optimize!)
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
			requires = {
				-- "nvim-treesitter/nvim-treesitter-textobjects",
				"romgrk/nvim-treesitter-context", -- show function context on top of buffer, very nice
				-- "RRethy/nvim-treesitter-textsubjects",
				-- "p00f/nvim-ts-rainbow",
				"windwp/nvim-ts-autotag",
			},
			config = function()
				vim.o.foldmethod = "expr"
				vim.o.foldexpr = "nvim_treesitter#foldexpr()"
				vim.o.foldlevel = 20

				require("nvim-treesitter.configs").setup({
					ensure_installed = "maintained",
					highlight = {
						enable = false,
					},
					autotag = {
						enable = true,
					},
					-- textsubjects = {
					-- 	enable = true,
					-- 	keymaps = {
					-- 		["."] = "textsubjects-smart",
					-- 		[";"] = "textsubjects-container-outer",
					-- 	},
					-- },
					-- textobjects = {
					-- 	swap = {
					-- 		enable = true,
					-- 		swap_next = {
					-- 			["]a"] = "@parameter.inner",
					-- 		},
					-- 		swap_previous = {
					-- 			["[a"] = "@parameter.inner",
					-- 		},
					-- 	},
					-- 	select = {
					-- 		enable = true,
					-- 		keymaps = {
					-- 			["af"] = "@function.outer",
					-- 			["if"] = "@function.inner",
					-- 			["ac"] = "@call.outer",
					-- 			["ic"] = "@call.inner",
					-- 		},
					-- 	},
					-- },
					-- rainbow = {
					-- 	enable = false,
					-- 	extended_mode = true,
					-- },
				})
			end,
		})

		-- Даже если включена русская раскладка vim команды будут работать
		use("powerman/vim-plugin-ruscmd")

		use({
			"editorconfig/editorconfig-vim",
			config = function()
				vim.cmd([[ let g:EditorConfig_exclude_patterns = ['fugitive://.*'] ]])
				vim.cmd([[ let g:EditorConfig_exec_path = '/usr/bin/editorconfig' ]])
				vim.cmd([[ let g:EditorConfig_core_mode = 'external_command' ]])
			end,
		})

		--A searchable cheatsheet for neovim from within the editor using Telescope
		use({
			"sudormrfbin/cheatsheet.nvim",
			config = function()
				local ws = require("which-key")
				ws.register({
					name = "Telescope",
					d = { "<cmd>Cheatsheet<CR>", "Cheatsheet" },
				}, {
					prefix = "<Leader>f",
				})
			end,
		})

		-- All the npm/yarn/pnpm commands I don't want to type
		-- now i hav a a bug where npm install runs in nvim folder
		use({
			"vuki656/package-info.nvim",
			requires = { "MunifTanjim/nui.nvim" },
			config = function()
				require("package-info").setup({
					colors = {
						up_to_date = "#3C4048", -- Text color for up to date package virtual text
						outdated = "#d19a66", -- Text color for outdated package virtual text
					},
					icons = {
						enable = true, -- Whether to display icons
						style = {
							up_to_date = "|  ", -- Icon for up to date packages
							outdated = "|  ", -- Icon for outdated packages
						},
					},
					autostart = true, -- Whether to autostart when `package.json` is opened
					hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
					hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
					-- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
					-- The plugin will try to auto-detect the package manager based on
					-- `yarn.lock` or `package-lock.json`. If none are found it will use the
					-- provided one, if nothing is provided it will use `yarn`
					package_manager = "pnpm",
				})
				-- selene: allow(global_usage)
				-- use only in package.json now
				function _G.setup_package_info_mappings()
					require("which-key").register({
						p = {
							name = "Package.json",
							u = { "<cmd>lua require('package-info').change_version()<CR>", "Install another version" },
							d = { "<cmd>lua require('package-info').delete()<CR>", "Delete package" },
						},
					}, {
						prefix = "<Leader>c",
						buffer = vim.fn.bufnr(),
					})
				end

				vim.cmd([[
          augroup PackageInfoMappings
            autocmd! BufEnter package.json lua _G.setup_package_info_mappings()
          augroup END
        ]])
			end,
		})

		-- nice right scrollbar
		use({
			"dstein64/nvim-scrollview",
			config = function()
				vim.cmd([[ highlight link ScrollView WildMenu ]])
			end,
		})

		-- session restore
		use({
			"folke/persistence.nvim",
			event = "BufReadPre", -- this will only start session saving when an actual file was opened
			module = "persistence",
			config = function()
				require("persistence").setup({
					dir = vim.fn.expand(vim.fn.stdpath("config") .. "/sessions/"), -- directory where session files are saved
					options = { "buffers", "curdir", "tabpages", "winsize" }, -- sessionoptions used for saving
				})
			end,
		})

		--
		-- autogenerate tags file
		use({
			"soramugi/auto-ctags.vim",
			config = function()
				vim.g.auto_ctags = 1
				vim.g.auto_ctags_directory_list = { ".git" }
				vim.g.auto_ctags_set_tags_option = 1
				vim.g.auto_ctags_tags_args = { "--tag-relative=yes", "--recurse=yes", "--sort=yes" }
			end,
		})

		-- lua formatter
		use({ "ckipp01/stylua-nvim" })

		-- resize / move windows mode ctrl+w+r
		use({
			"simeji/winresizer",
			config = function()
				require("which-key").register({
					r = { ":WinResizerStartResize<CR>", "WinResizer" },
				}, {
					prefix = "<C-w>",
				})
			end,
		})

		-- A small Neovim plugin for previewing native LSP's goto definition calls in floating windows.
		-- use({
		-- 	"rmagatti/goto-preview",
		-- 	config = function()
		-- 		require("which-key").register({
		-- 			["gpd"] = {
		-- 				[[<cmd>lua require('goto-preview').goto_preview_definition()<CR>]],
		-- 				"Preview definitions",
		-- 			},
		-- 			["gpi"] = {
		-- 				[[<cmd>lua require('goto-preview').goto_preview_implementation()<CR>]],
		-- 				"Preview implementations",
		-- 			},
		-- 			["gP"] = { [[<cmd>lua require('goto-preview').close_all_win()<CR>]], "Close preview windows" },
		-- 		})
		-- 		require("goto-preview").setup({})
		-- 	end,
		-- })

		-- https://github.com/wbthomason/packer.nvim#bootstrapping
		if packer_bootstrap then
			require("packer").sync()
		end
	end)
end

if vim.g.plugins_recompile == 1 then
	setup_packer(false)
end

return setup_packer
