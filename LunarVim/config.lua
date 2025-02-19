-- Constants for this run
WINDOWS = vim.loop.os_uname().sysname == "Windows_NT"
-- Some organizations may not allow Copilot
COPILOT_ENABLED = os.getenv("DISABLE_COPILOT") == nil
-- WezTerm for smart splits (and more?)
WEZTERM = os.getenv("WEZTERM_PANE") ~= nil

-- Tree-sitter settings to remove annoying comment highlighting
lvim.builtin.treesitter.ensure_installed = {
    "markdown",
    "html",
    "python",
    "lua",
    "json",
    "yaml",
    "toml",
    "rust",
    "latex",
    "embedded_template",
}

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
vim.opt.virtualedit = "block"

-- Migrate to indentline v3
lvim.builtin.indentlines.active = false

-- Listchars
local listchars = {
    tab = ">-",
    -- eol = '↲',
    -- space = '⋅', -- A lot of clutter; TODO: highlight leading spaces only
    trail = "•",
    extends = "◀",
    precedes = "▶",
}

vim.opt.list = true
vim.opt.listchars = listchars
vim.opt.showbreak = "↪"

local function toggle_eol_chars()
    if listchars.eol == "↲" then
        listchars.eol = "¶"
        vim.opt.listchars = listchars
    elseif listchars.eol == "¶" then
        listchars.eol = nil
        vim.opt.listchars = listchars
    else
        listchars.eol = "↲"
        vim.opt.listchars = listchars
    end
end

local function toggle_colorcolumn()
    local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", {})
    local textwidth = vim.api.nvim_get_option_value("textwidth", {})
    if textwidth ~= 0 then
        vim.notify("Unsetting textwidth")
        vim.opt.textwidth = 0
    end
    if colorcolumn == "" then
        vim.notify("80 columns")
        vim.opt.colorcolumn = "81"
    elseif colorcolumn == "81" then
        vim.opt.colorcolumn = "121"
        vim.notify("120 columns")
    else
        vim.opt.colorcolumn = ""
        vim.notify("  columns")
    end
end

local function toggle_textwidth()
    local current_colorcolumn = vim.api.nvim_get_option_value("colorcolumn", {})
    if current_colorcolumn == "" then
        vim.notify("Unsetting textwidth, as colorcolumn is not set")
        vim.opt.textwidth = 0
        return
    end
    local current_textwidth = vim.api.nvim_get_option_value("textwidth", {})
    if current_textwidth ~= tonumber(current_colorcolumn) - 1 then
        vim.opt.textwidth = tonumber(current_colorcolumn) - 1
        vim.notify("Setting textwidth to " .. (current_colorcolumn - 1))
    else
        vim.opt.textwidth = 0
        vim.notify("Unsetting textwidth")
    end
end

local function toggle_rainbow_delimiters()
    local rainbow = require("rainbow-delimiters")
    if rainbow.is_enabled() then
        vim.notify("Disabling rainbow delimiters")
        rainbow.disable()
    else
        vim.notify("Enabling rainbow delimiters")
        rainbow.enable()
    end
end

-- lvim.transparent_window = true
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.cmd("highlight Normal guibg=none ctermbg=none")
    end,
})

lvim.plugins = {
    {
        "github/copilot.vim",
        enabled = COPILOT_ENABLED,
        build = ":Copilot auth",
    },
    "tpope/vim-surround",
    "tpope/vim-sleuth",
    {
        "tpope/vim-eunuch",
        cond = not WINDOWS,
    },
    {
        "jiaoshijie/undotree",
        dependencies = "nvim-lua/plenary.nvim",
        config = true,
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
        },
    },
    {
        "bbjornstad/pretty-fold.nvim",
        event = "BufEnter",
        opts = {
            keep_indentation = false,
            fill_char = "━",
            sections = {
                left = {
                    "━ ",
                    function()
                        return string.rep(">", vim.v.foldlevel)
                    end,
                    " ━┫",
                    "content",
                    "┣━━━┫ ",
                    "number_of_folded_lines",
                    " ┣━",
                },
                right = {},
            },
        },
    },
    {
        "NvChad/nvim-colorizer.lua",
        event = "BufEnter",
        opts = {
            filetypes = {
                "*",
                css = { rgb_fn = true },
                scss = { rgb_fn = true },
                html = { rgb_fn = true },
            },
            user_default_options = {
                names = false,
            },
        },
    },
    {
        "unblevable/quick-scope",
        keys = { "f", "F", "t", "T" },
    },
    {
        "folke/todo-comments.nvim",
        event = "BufEnter",
        opts = {},
    },
    {
        "vim-scripts/abnf",
        ft = "abnf",
    },
    "tpope/vim-repeat",
    {
        "MeanderingProgrammer/markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            headings = {
                "󰲡 ",
                "#󰲣 ",
                "##󰲥 ",
                "###󰲧 ",
                "####󰲩 ",
                "#####󰲫 ",
            },
            -- Disable heading coloring
            heading = {
                backgrounds = {},
                foregrounds = { "@punctuation.special.markdown" },
            },
        },
        ft = "markdown",
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            columns = { "permissions", "size", "mtime", "icon" },
            view_options = {
                show_hidden = true,
            },
            win_options = {
                signcolumn = "yes:2",
            },
            constrain_cursor = "name",
        },
    },
    {
        "refractalize/oil-git-status.nvim",
        config = true,
    },
    {
        -- Breaks markdown rendering which links some hl to colorcolumn
        enabled = false,
        "Bekaboo/deadcolumn.nvim",
        event = "BufEnter",
        opts = {
            modes = function(_)
                return true
            end,
            blending = {
                hlgroup = { "SignColumn", "bg" },
            },
        },
    },
    {
        "2KAbhishek/nerdy.nvim",
        dependencies = { "stevearc/dressing.nvim" },
    },
    {
        "bennypowers/nvim-regexplainer",
        event = "BufEnter",
        config = true,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "MunifTanjim/nui.nvim",
        },
        opts = { auto = true },
    },
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
    },
    {
        "nanotee/zoxide.vim",
        dependencies = { "junegunn/fzf.vim" },
        cmd = {
            "Cd",
            "Cdi",
            "Jcd",
            "Jcdi",
            "Lcd",
            "Lcdi",
            "Tcd",
            "Tcdi",
        },
        init = function()
            vim.g.zoxide_prefix = "cd"
            vim.g.zoxide_uses_select = 1
        end,
    },
    {
        "ekorchmar/zen-mode.nvim",
        cmd = "ZenMode",
        branch = "konsole",
        opts = {
            window = {
                backdrop = 0.6,
                width = function()
                    local wide = {
                        markdown = true,
                        html = true,
                        text = true,
                        abnf = true,
                    }
                    if wide[vim.bo.filetype] then
                        return 0.8 * vim.o.columns
                    end

                    return 0.618 * vim.o.columns
                end,
                options = {
                    signcolumn = "no",
                    colorcolumn = "",
                },
            },
            plugins = {
                wezterm = { enabled = true, font = "+0" },
                konsole = { enabled = true, profile = true },
            },
            on_open = function()
                vim.opt.laststatus = 0
                vim.opt.cmdheight = 0

                lvim.builtin.breadcrumbs.active = false
            end,
            on_close = function()
                vim.opt.laststatus = 3
                vim.opt.cmdheight = 2

                lvim.builtin.breadcrumbs.active = true
            end,
        },
    },
    "vim-scripts/RemoveDups.VIM",
    "vim-scripts/ReplaceWithRegister",
    {
        "iamcco/markdown-preview.nvim",
        cmd = {
            "MarkdownPreviewToggle",
            "MarkdownPreview",
            "MarkdownPreviewStop",
        },
        build = "!\\cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_page_title = "${name}"
        end,
        ft = { "markdown" },
    },
    {
        "tpope/vim-fugitive",
        dependencies = { "tommcdo/vim-fubitive" },
    },
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap-python",
        },
        opts = {
            search_venv_managers = false,
            name = { "venv", ".venv" },
        },
        cmd = "VenvSelect",
        keys = { "<leader>cP" },
    },
    {
        "lervag/vimtex",
        ft = "tex",
        init = function()
            vim.g.vimtex_view_general_options =
                "--unique file:@pdf\\#src:@line@tex"
            if WINDOWS then
                vim.g.vimtex_view_general_viewer =
                    "C:\\Program Files\\Okular\\bin\\okular.exe"
            else
                vim.g.vimtex_view_general_viewer = "okular"
            end

            vim.g.maplocalleader = "^"
        end,
    },
    {
        "2kabhishek/co-author.nvim",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-telescope/telescope.nvim",
        },
        cmd = { "CoAuthor" },
    },
    {
        "chrisgrieser/nvim-origami",
        event = "BufReadPost",
        opts = {},
    },
    -- "mong8se/actually.nvim", -- breaks undotree
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle" },
        opts = {
            backends = { "lsp", "treesitter", "markdown", "man" },
            filter_kind = false,
            layout = { min_width = 28 },
            show_guides = true,
            highlight_on_hover = true,
            autojump = true,
            manage_folds = true,
            link_folds_to_tree = true,
            link_tree_to_folds = true,
            guides = {
                mid_item = "├ ",
                last_item = "└ ",
                nested_top = "│ ",
                whitespace = "  ",
            },
            keymaps = {
                ["[y"] = "actions.prev",
                ["]y"] = "actions.next",
                ["[Y"] = "actions.prev_up",
                ["]Y"] = "actions.next_up",
                ["{"] = false,
                ["}"] = false,
                ["[["] = false,
                ["]]"] = false,
            },
        },
    },
    {
        "stevearc/stickybuf.nvim",
        opts = {},
    },
    "MTDL9/vim-log-highlighting",
    {
        "mawkler/modicator.nvim",
        opts = {},
    },
    {
        "kaarmu/typst.vim",
        ft = "typst",
    },
    {
        "chomosuke/typst-preview.nvim",
        ft = "typst",
        version = "1.*",
        build = function()
            require("typst-preview").update()
        end,
    },
    {
        "goerz/jupytext.vim",
        config = function()
            vim.g.jupytext_fmt = "py"
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufRead",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            dashboard = { enabled = false },
            explorer = { enabled = false },
            indent = { enabled = false },
            input = { enabled = true },
            picker = { enabled = false },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = false },
            words = { enabled = true },
        },
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        event = "BufRead",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "lukas-reineke/indent-blankline.nvim",
        },
        init = function()
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
            end)
            vim.g.rainbow_delimiters = { highlight = highlight }
            require("ibl").setup({ scope = { highlight = highlight } })
            hooks.register(
                hooks.type.SCOPE_HIGHLIGHT,
                hooks.builtin.scope_highlight_from_extmark
            )
        end,
    },
    {
        "mrjones2014/smart-splits.nvim",
        opts = {},
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        enabled = true,
        main = "ibl",
        config = function()
            -- NOOP
        end,
        opts = {
            exclude = {
                buftypes = { "terminal", "nofile" },
                filetypes = {
                    "help",
                    "startify",
                    "dashboard",
                    "lazy",
                    "neogitstatus",
                    "NvimTree",
                    "Trouble",
                    "text",
                },
            },
            indent = { char = lvim.icons.ui.LineLeft },
        },
    },
}

-- Snacks options
vim.g.snacks_animate = false

-- I know how to use the mouse, thanks
vim.cmd.aunmenu({ [[PopUp.How-to\ disable\ mouse]] })
vim.cmd.aunmenu({ [[PopUp.-1-]] })

-- Custom terminal
lvim.builtin.terminal.size = 80
local function toggle_terminal(cmd)
    return function()
        local Terminal = require("toggleterm.terminal").Terminal
        local term = Terminal:new({
            cmd = cmd or vim.o.shell,
            hidden = true,
            direction = "vertical",
            on_open = function(_)
                vim.opt_local.signcolumn = "no"
                vim.cmd("startinsert!")
            end,
            on_close = function(_) end,
            count = 99,
        })
        term:toggle()
    end
end

-- Which key mappings (normal mode)
local nor = lvim.builtin.which_key.mappings
nor["bq"] = { "<cmd>BufferKill<cr>", "Close current buffer" }
nor["bo"] = { "<cmd>BufferLineCloseOther<cr>", "Close other buffers" }
nor["ga"] = { "<cmd>CoAuthor<cr>", "Add a co-author to a commit message" }
nor["gg"] = {} -- Lazygit is in terminal menu
nor["gO"] = { require("snacks").gitbrowse.open, "Open remote in browser" }
nor["sd"] = { "<cmd>TodoTelescope<cr>", "TODO comments" }
nor["sn"] = {
    function()
        local telescope = require("telescope")
        if not telescope.extensions.nerdy then
            telescope.load_extension("nerdy")
        end
        vim.cmd("Nerdy")
    end,
    "Nerd font symbols",
}
nor["u"] = { "<cmd>lua require('undotree').toggle()<cr>", "Undo Tree" }
nor["z"] = { "<cmd>ZenMode<cr>", "Zen mode" }
nor["-"] = { "<cmd>Oil<cr>", "View parent as buffer" }
-- Remove unneeded and duplicating menus
nor["w"] = {}
nor["T"] = {}
nor["f"] = {}
nor["lr"] = { vim.lsp.buf.rename, "Rename symbol" }
nor["lA"] = { "<cmd>AerialToggle<cr>", "Symbol tree outline" }
nor["p"] = {}
-- Redefine some default menus
nor["c"] = {
    name = "Commands",
    c = { "<cmd>ClangdSwitchSourceHeader<cr>", "C/C++ header switch" },
    l = { "<cmd>Lazy<cr>", "Lazy (manage installed plugins)" },
    m = { "<cmd>Mason<cr>", "Mason (manage LSP)" },
    t = { "<cmd>StartupTime<cr>", "Startup time profile" },
    y = { "<cmd>TypstPreview<cr>", "Typst preview in browser" },
    M = { "<cmd>MarkdownPreview<cr>", "Markdown preview in browser" },
    P = { "<cmd>VenvSelect<cr>", "Select Python venv" },
    S = { "<cmd>SudoWrite<cr>", "Save with sudo" },
}
nor["q"] = {
    name = "Quick options",
    b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle inline blame" },
    c = { "<cmd>windo set scrollbind<cr>", "Scrollbind all windows" },
    d = { "<cmd>windo diffthis<cr>", "Diff all windows" },
    e = { toggle_eol_chars, "Toggle EOL ↲/¶/None" },
    o = { toggle_colorcolumn, "Toggle colorcolumn" },
    p = {
        function()
            local enabled = vim.api.nvim_get_option_value("paste", {})
            vim.notify(enabled and "Normal input mode" or "Paste input mode")
        end,
        "Toggle paste mode",
    },
    r = { toggle_rainbow_delimiters, "Toggle rainbow delimiters" },
    s = {
        function()
            local enabled = vim.api.nvim_get_option_value("spell", {})
            if enabled then
                vim.notify("Disbaling spelchek. Good lcuk!", "warn")
            else
                vim.notify("Enabling spellcheck", "info")
            end
            vim.opt.spell = not enabled
        end,
        "Toggle spell check",
    },
    u = {
        "<cmd>windo set noscrollbind<cr>" .. "<cmd>windo diffoff<cr>",
        "Unscrollbind/undiff windows",
    },
    v = {
        function()
            local ve = vim.api.nvim_get_option_value("virtualedit", {})
            if ve == "block,onemore" then
                vim.notify("Only block mode virtualedit")
                vim.opt.virtualedit = "block"
            elseif ve == "block" then
                vim.notify("All modes virtualedit")
                vim.opt.virtualedit = "all"
            else -- all
                vim.notify("Virtual EOL")
                vim.opt.virtualedit = "block,onemore"
            end
        end,
        "Toggle virtualedit",
    },
    w = { toggle_textwidth, "Toggle textwidth" },
    C = {
        function()
            local has_col = vim.api.nvim_get_option_value("cursorcolumn", {})
            local has_lin = vim.api.nvim_get_option_value("cursorline", {})
            if not has_col and not has_lin then
                vim.opt.cursorline = true
                vim.notify("Enabled cursorline")
            elseif has_lin and not has_col then
                vim.opt.cursorcolumn = true
                vim.notify("Enabled cursorcolumn")
            else
                vim.opt.cursorline = false
                vim.opt.cursorcolumn = false
                vim.notify("Enabled neither")
            end
        end,
        "Toggle cursorline/column",
    },
}
nor["H"] = {
    require("snacks").notifier.show_history,
    "Show notification history",
}

-- Manage window movement by smart-splits
lvim.keys.normal_mode["<C-h>"] = require("smart-splits").move_cursor_left
lvim.keys.normal_mode["<C-j>"] = require("smart-splits").move_cursor_down
lvim.keys.normal_mode["<C-k>"] = require("smart-splits").move_cursor_up
lvim.keys.normal_mode["<C-l>"] = require("smart-splits").move_cursor_right

if WINDOWS then
    -- Terminals are only useful on Windows, because Ctrl+Z is not a thing
    nor["t"] = {
        name = "Terminal",
        d = { toggle_terminal("lazydocker"), "Lazydocker" },
        g = { require("snacks").lazygit.open, "Lazygit" },
        i = { toggle_terminal("ipython"), "Python REPL (IPython)" },
        n = { toggle_terminal("node"), "Node REPL" },
        p = { toggle_terminal("python"), "Python REPL (cPython)" },
        t = { toggle_terminal(), "Default shell" },
    }
else
    -- Unbind
    nor["t"] = nil
end

-- Which key mappings (visual mode)
local vis = lvim.builtin.which_key.vmappings
vis["c"] = {
    name = "Commands",
    d = { ":'<,'>call RemoveDups()<cr>", "Remove duplicate lines" },
    s = { ":'<,'>sort<cr>", "Sort lines" },
    u = { ":'<,'>sort u<cr>", "Sort unique lines" },
}

lvim.builtin.which_key.setup.plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = true,
    spelling = {
        enabled = true,
        suggestions = 20,
    },
}

lvim.builtin.which_key.setup.presets = {
    operators = true,
    motions = true,
    text_objects = true,
    windows = true, -- default bindings on <c-w>
    nav = true, -- misc bindings to work with windows
    z = true, -- bindings for folds, spelling and others prefixed with z
    g = true, -- bindings for prefixed with g
}

-- Lualine to show mode name
lvim.builtin.lualine.sections.lualine_a = {
    {
        "mode",
        fmt = function(str)
            return string.lower(lvim.icons.ui.Target .. " " .. str)
        end,
    },
}

-- Copilot
vim.g.copilot_filetypes = { markdown = true }
vim.g.copilot_no_tab_map = true
-- Accept suggestions with Ctrl+a
vim.keymap.set("i", "<C-a>", 'copilot#Accept("")', {
    expr = true,
    replace_keycodes = false,
})

-- Windows specific
if WINDOWS then
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

-- Set wrap for markdown and like
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "html", "xml", "text", "abnf" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.colorcolumn = "121"
        vim.opt_local.textwidth = 120
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "yaml", "typst" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.colorcolumn = "81"
        vim.opt_local.textwidth = 80
    end,
})

-- Vim surround:
-- "c" for C-style multiline comments
vim.g.surround_99 = "/* \r */"
-- "h" for HTML comment
vim.g.surround_104 = "<!-- \r -->"
-- 1 through 6 for h1 through h6
vim.g.surround_49 = "<h1>\r</h1>"
vim.g.surround_50 = "<h2>\r</h2>"
vim.g.surround_51 = "<h3>\r</h3>"
vim.g.surround_52 = "<h4>\r</h4>"
vim.g.surround_53 = "<h5>\r</h5>"
vim.g.surround_54 = "<h6>\r</h6>"
-- "p" for paragraph
vim.g.surround_112 = "<p>\r</p>"
-- "d" for div
vim.g.surround_100 = "<div>\r</div>"
-- "s" for span
vim.g.surround_115 = "<span>\r</span>"
-- "a" for anchor (puts text in href)
vim.g.surround_97 = '<a href="\r"></a>'
-- "A" for anchor (puts text inside tag)
vim.g.surround_65 = '<a href="">\r</a>'
-- "i" for image (puts text in src)
vim.g.surround_105 = '<img src="\r">'
-- "P" for Python """ multiline string/Docstring
vim.g.surround_80 = '"""\n\r\n"""'
-- "Q" for Qlik set selector
vim.g.surround_81 = "{< \r; >}"
-- "m" for markdown link (text is in [])
vim.g.surround_109 = "[\r](url)"
-- "M" for markdown link (text is in ())
vim.g.surround_77 = "[text](\r)"

-- Quick scope settings
vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }

-- Filetypes:
-- ABNF
vim.filetype.add({
    extension = {
        abnf = "abnf",
    },
})

-- Check if JSON for .conf and .etlconf
vim.filetype.add({
    extension = {
        etlconf = "yaml",
        conf = "yaml",
        -- .envrc is shell
        envrc = "bash",
        -- EJS is HTML
        ejs = "html",
        -- log is log
        log = "log",
    },
})

-- Autocommands to set linenumber & signcolumn background for better contrast
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.cmd([[
          highlight ColorColumn     guibg=black ctermbg=0
          highlight LineNr          guibg=#13141b ctermbg=232
          highlight CursorLineNr    guibg=#13141b ctermbg=232
          highlight SignColumn      guibg=#13141b ctermbg=232
          highlight GitSignsAdd     guibg=#13141b ctermbg=232
          highlight GitSignsChange  guibg=#13141b ctermbg=232
          highlight GitSignsDelete  guibg=#13141b ctermbg=232
    ]])
    end,
})

-- Zoxide
vim.g.zoxide_prefix = "cd"
vim.g.zoxide_uses_select = 1

-- Set the terminal to override ANSI colors (lunar color scheme does not)
-- The OG eight
vim.g.terminal_color_0 = "#2a2b3d" -- Black
vim.g.terminal_color_1 = "#f7768e" -- Red
vim.g.terminal_color_2 = "#9ece6a" -- Green
vim.g.terminal_color_3 = "#e0af68" -- Yellow
vim.g.terminal_color_4 = "#7aa2f7" -- Blue
vim.g.terminal_color_5 = "#ad8ee6" -- Magenta
vim.g.terminal_color_6 = "#7dcfff" -- Cyan
vim.g.terminal_color_7 = "#787c99" -- White
-- The bright bunch
vim.g.terminal_color_8 = "#3b3d57" -- Black
vim.g.terminal_color_9 = "#ff7a95" -- Red
vim.g.terminal_color_10 = "#afe274" -- Green
vim.g.terminal_color_11 = "#f4bd71" -- Yellow
vim.g.terminal_color_12 = "#7ea9ff" -- Blue
vim.g.terminal_color_13 = "#bc9afa" -- Magenta
vim.g.terminal_color_14 = "#91d7ff" -- Cyan
vim.g.terminal_color_15 = "#888dad" -- White

-- Alpha header
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.alpha.dashboard.section.header.val = {
    [[┌──────────────────────────────────────────────┐]],
    [[│                                              │]],
    [[│         _               _     _              │]],
    [[│        (_)             | |   | |             │]],
    [[│  __   ___ _ __ ___     | |__ | |___      __  │]],
    [[│  \ \ / / | '_ ` _ \    | '_ \| __\ \ /\ / /  │]],
    [[│   \ V /| | | | | | |_  | |_) | |_ \ V  V /   │]],
    [[│    \_/ |_|_| |_| |_( ) |_.__/ \__| \_/\_/    │]],
    [[│                    |/                        │]],
    [[│                                              │]],
    [[└──────────────────────────────────────────────┘]],
}

-- Gitsigns
lvim.builtin.gitsigns.opts.current_line_blame = true

-- Telescope wrap
lvim.builtin.telescope.defaults.wrap_results = true

-- LSP
-- Disable annoying suggestion in every JS file
-- https://github.com/LunarVim/LunarVim/discussions/4239
local function filter_tsserver_diag(_, result, ctx, config)
    if result.diagnostics == nil then
        return
    end
    -- ignore some tsserver diagnostics
    local idx = 1
    while idx <= #result.diagnostics do
        local entry = result.diagnostics[idx]
        if entry.code == 80001 then
            table.remove(result.diagnostics, idx)
        else
            idx = idx + 1
        end
    end
    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end
vim.lsp.handlers["textDocument/publishDiagnostics"] = filter_tsserver_diag

-- Remove "o" from fo-table
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})
