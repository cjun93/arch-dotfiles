-- === General ===
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.scrolloff = 8
vim.opt.undofile = true

-- Colorscheme
vim.cmd("colorscheme habamax")

-- === Leader key ===
vim.g.mapleader = " "

-- === File type templates ===
local tpl_dir = vim.fn.stdpath("config") .. "/templates/"
local templates = {
    sh = "bash.tpl",
    py = "python.tpl",
    c = "c.tpl",
    h = "h.tpl",
    html = "html.tpl",
    make = "makefile.tpl",
}

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*",
    callback = function()
        local ext = vim.fn.expand("%:e")
        local fname = vim.fn.expand("%:t")
        local key = ext
        if fname == "Makefile" then key = "make" end
        if templates[key] then
            local tpl = tpl_dir .. templates[key]
            if vim.fn.filereadable(tpl) == 1 then
                vim.cmd("0r " .. tpl)
            end
        end
    end,
})
