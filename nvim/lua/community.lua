-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

local AC = "astrocommunity."
local C = AC .. "colorscheme."
local E = AC .. "editing-support."
local R = AC .. "recipes."
local P = AC .. "pack.python."
local T = AC .. "terminal-integration."

---@type LazySpec
local spec = {

    "AstroNvim/astrocommunity",

    { import = AC .. "docker.lazydocker" },
    { import = AC .. "motion.nvim-surround" },

    { import = C .. "tokyonight-nvim" },
    { import = C .. "rose-pine" },
    { import = C .. "catppuccin" },

    { import = E .. "hypersonic-nvim" },
    { import = E .. "nvim-origami" },
    { import = E .. "nvim-regexplainer" },
    { import = E .. "nvim-treesitter-context" },
    { import = E .. "stickybuf-nvim" },
    { import = E .. "quick-scope" },
    { import = E .. "suda-vim" },
    { import = E .. "todo-comments-nvim" },
    { import = E .. "undotree" },

    { import = R .. "cache-colorscheme" },
    { import = R .. "diagnostic-virtual-lines-current-line" },
    { import = R .. "astrolsp-no-insert-inlay-hints" },
    { import = R .. "heirline-vscode-winbar" },
    { import = R .. "heirline-nvchad-statusline" },
    { import = R .. "vscode" },

    { import = P .. "base" },
    { import = P .. "basedpyright" },
    { import = P .. "ruff" },
}

-- tmux specific
if vim.env.TMUX then
    table.insert(spec, { import = T .. "vim-tmux-navigator" })
    table.insert(spec, { import = T .. "vim-tmux-yank" })
end

-- Languages
local langs = {
    "bash",
    "cpp",
    "docker",
    "html-css",
    "json",
    "just",
    "lua",
    "markdown",
    "ps1",
    "rust",
    "sql",
    "toml",
    "typst",
    "yaml",
}

for _, lang in pairs(langs) do
    ---@diagnostic disable-next-line
    table.insert(spec, { import = AC .. "pack." .. lang })
end

return spec
