-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

local AC = "astrocommunity."
local P = AC .. "pack."
local E = AC .. "editing-support."
local R = AC .. "recipes."

---@type LazySpec
local spec = {

  "AstroNvim/astrocommunity",

  { import = AC .. "bars-and-lines.lualine-nvim" },
  { import = AC .. "colorscheme.tokyonight-nvim" },
  { import = AC .. "colorscheme.rose-pine" },
  { import = AC .. "docker.lazydocker" },
  { import = AC .. "recipes.vscode" },
  { import = AC .. "motion.nvim-surround" },

  { import = P .. "rainbow-delimiter-indent-blankline" },

  { import = E .. "dial-nvim" },
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
  { import = R .. "astrolsp-no-insert-inlay-hints" },
  { import = R .. "heirline-vscode-winbar" },
}

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
  "python-ruff",
  "rust",
  "sql",
  "toml",
  "typst",
  "yaml",
}

for _, lang in pairs(langs) do
  ---@diagnostic disable-next-line
  table.insert(spec, { import = P .. lang })
end

return spec
