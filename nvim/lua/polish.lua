vim.g.autoformat = false
vim.opt.cmdheight = 2
vim.opt.colorcolumn = "81"
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Listchars
local listchars = {
    tab = ">-",
    -- eol = '↲',
    -- space = '⋅', -- A lot of clutter;
    trail = "•",
    extends = "◀",
    precedes = "▶",
}

vim.opt.list = true
vim.opt.listchars = listchars
vim.opt.showbreak = "↪"

-- Remove "o" from fo-table - disables automated comments
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

vim.cmd[[colorscheme tokyonight]]
