local cmd = vim.cmd -- execute Vim commands
local exec = vim.api.nvim_exec -- execute Vimscript
local g = vim.g -- global variables
local opt = vim.opt -- global/buffer/windows-scoped options
local o = vim.o
-- read interesting thread about o and opt
-- https://www.reddit.com/r/neovim/comments/qgwkcu/difference_between_vimo_and_vimopt/

-- esc timeout
o.timeoutlen = 0
o.ttimeoutlen = 0

-- ignore total
opt.wildignore = { "*/cache/*", "*/tmp/*", "*/vendor/*" } -- ignore total

-- use space as a the leader key
g.mapleader = " "

o.relativenumber = true
o.cursorline = true
o.number = true
o.numberwidth = 2
o.ignorecase = true
o.smartcase = true
o.wrap = true
o.mouse = "a"
o.scrolloff = 5
o.sidescrolloff = 8
o.hidden = true
o.writebackup = false
o.autowrite = false
o.swapfile = false
o.signcolumn = "yes:2"
o.splitbelow = true
-- o.splitright = true
-- o.so = 999 -- Cursor always at center a screen
o.undofile = true
o.splitright = true
o.splitbelow = true

o.autoindent = true
o.smartindent = true

-- vim.cmd([[filetype plugin indent on]]) -- look into autocommands
-- vim.cmd([[set autoindent]])

o.colorcolumn = "+1,120"
o.updatetime = 100
o.clipboard = "unnamedplus" -- shared clipboard with the system
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.softtabstop = 2

o.termguicolors = true -- 24 bit rgb colors

opt.diffopt:append("algorithm:histogram,iwhite,indent-heuristic,vertical")

-- Use ripgrep instead of regular grep
if vim.fn.executable("rg") then
	vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
else
	vim.fn.echoerr("rg (ripgrep) is not installed. Thus, it will not be used for :grep")
end

-- Highlight on yank
vim.cmd([[
  augroup HighlightYank
    autocmd! TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=200 }
  augroup END
]])

-- jump to the last position when reopening a file
cmd([[
if has("autocmd")
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
]])

cmd([[
  " close buffer without changing window layout
  nnoremap :: :bp\|bd #<CR>
]])

-- autosessions
-- cmd([[
-- augroup manage_session
--     au!
--    au VimEnter * lua require("persistence").load({ last = true })
--augroup END

-- remove whitespace on save
cmd([[au BufWritePre * :%s/\s\+$//e]])

-- faster scrolling
opt.lazyredraw = true
-- don't auto commenting new lines
cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
-- completion options
opt.completeopt = "menuone,noselect,noinsert"

-- Bootstrap packer
-- https://github.com/wbthomason/packer.nvim#bootstrapping
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

require("plugins")(packer_bootstrap)
require("keymaps")
require("autocommands")
