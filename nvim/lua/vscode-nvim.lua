-- Only loaded when Neovim is started from VSCode
vim.g.shiftwidth = 4
vim.opt.autochdir = true
vim.opt.cmdheight = 2
vim.opt.colorcolumn = "81"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.virtualedit = "block,onemore"
vim.opt.wrap = false
vim.clipboard = "unnamedplus"

if vim.loop.os_uname().sysname == "Windows_NT" then
    -- Enable powershell as your default shell
    vim.opt.shell = "pwsh.exe -NoLogo"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::"
        .. "InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.cmd([[
      let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
      let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
      set shellquote= shellxquote=
    ]])

    -- Set a compatible clipboard manager
    vim.g.clipboard = {
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
    }
end
