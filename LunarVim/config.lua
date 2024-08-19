-- Constants for this run
NEOVIDE = vim.g.neovide
WINDOWS = vim.loop.os_uname().sysname == "Windows_NT"
COPILOT_ENABLED = true

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
vim.opt.virtualedit = "block,onemore"

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

function Toggle_copilot()
    if COPILOT_ENABLED then
        vim.cmd("Copilot disable")
        COPILOT_ENABLED = false
    else
        vim.cmd("Copilot enable")
        COPILOT_ENABLED = true
    end
end

function Toggle_eol_chars()
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

function Toggle_colorcolumn()
    local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", {})
    if colorcolumn == "" then
        print("80 columns")
        vim.opt.colorcolumn = "81"
    else
        if colorcolumn == "81" then
            vim.opt.colorcolumn = "121"
            print("120 columns")
        else
            vim.opt.colorcolumn = ""
            print("  columns")
        end
    end
end

if not NEOVIDE then
    -- Does not respect signcolumn background autocommands
    -- lvim.transparent_window = true
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
            vim.cmd("highlight Normal guibg=none ctermbg=none")
        end,
    })
end

lvim.plugins = {
    {
        "github/copilot.vim",
        build = ":Copilot auth",
        init = function()
            if not COPILOT_ENABLED then
                vim.cmd("Copilot disable")
            end
        end,
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
            constrain_cursor = "name",
        },
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
                wezterm = { enabled = true, font = "+2" },
                neovide = { enabled = true },
                konsole = { enabled = true, profile = true },
            },
            on_open = function()
                vim.opt.laststatus = 0
                vim.opt.cmdheight = 0

                -- For neovide: go full screen
                if NEOVIDE and not vim.g.neovide_fullscreen then
                    vim.g.neovide_fullscreen = true
                end

                lvim.builtin.breadcrumbs.active = false
            end,
            on_close = function()
                vim.opt.laststatus = 3
                vim.opt.cmdheight = 2

                if NEOVIDE and vim.g.neovide_fullscreen then
                    vim.g.neovide_fullscreen = false
                end

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
        build = "!cd app && npm install",
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
}

-- I know how to use the mouse, thanks
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse" })
vim.cmd.aunmenu({ "PopUp.-1-" })

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
nor.g.g = { toggle_terminal("lazygit"), "Lazygit" }
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
    M = { "<cmd>MarkdownPreview<cr>", "Markdown preview in browser" },
    P = { "<cmd>VenvSelect<cr>", "Select Python venv" },
    S = { "<cmd>SudoWrite<cr>", "Save with sudo" },
}
nor["q"] = {
    name = "Quick options",
    a = { Toggle_copilot, "Toggle GitHub copilot" },
    b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle inline blame" },
    c = { "<cmd>windo set scrollbind<cr>", "Scrollbind all windows" },
    d = { "<cmd>windo diffthis<cr>", "Diff all windows" },
    e = { Toggle_eol_chars, "Toggle EOL ↲/¶/None" },
    o = { Toggle_colorcolumn, "Toggle colorcolumn" },
    p = {
        function()
            print(
                vim.api.nvim_get_option_value("paste", {}) and "Normal"
                    or "Paste"
            )
            vim.opt.paste = not vim.api.nvim_get_option_value("paste", {})
        end,
        "Toggle paste mode",
    },
    s = {
        function()
            print(
                vim.api.nvim_get_option_value("spell", {}) and "nospell"
                    or "spell"
            )
            vim.opt.spell = not vim.api.nvim_get_option_value("spell", {})
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
                print("Block")
                vim.opt.virtualedit = "block"
            elseif ve == "block" then
                print("All")
                vim.opt.virtualedit = "all"
            else -- all
                print("Onemore")
                vim.opt.virtualedit = "block,onemore"
            end
        end,
        "Toggle virtualedit",
    },
    C = {
        function()
            local has_col = vim.api.nvim_get_option_value("cursorcolumn", {})
            local has_lin = vim.api.nvim_get_option_value("cursorline", {})
            if not has_col and not has_lin then
                vim.opt.cursorline = true
                print("cursorline")
            elseif has_lin and not has_col then
                vim.opt.cursorcolumn = true
                print("cursorcolumn")
            else
                vim.opt.cursorline = false
                vim.opt.cursorcolumn = false
                print("none")
            end
        end,
        "Toggle cursorline/column",
    },
}
nor["t"] = {
    name = "Terminal",
    d = { toggle_terminal("lazydocker"), "Lazydocker" },
    g = { toggle_terminal("lazygit"), "Lazygit" },
    i = { toggle_terminal("ipython"), "Python REPL (IPython)" },
    l = { toggle_terminal("lua"), "Lua REPL" },
    n = { toggle_terminal("node"), "Node REPL" },
    p = { toggle_terminal("python"), "Python REPL (cPython)" },
    t = { toggle_terminal(), "Default shell" },
}

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

-- GUI settings
if vim.fn.has("gui_running") == 1 then
    vim.cmd("set guifont=FiraCode\\ Nerd\\ Font:h13")

    if NEOVIDE then
        vim.g.neovide_hide_mouse_when_typing = 1
        vim.g.neovide_cursor_animate_in_insert_mode = false
        vim.g.neovide_cursor_animate_command_line = true
        vim.g.neovide_scroll_animation_length = 0.1
        vim.g.neovide_scroll_animation_far_lines = 0
        vim.g.neovide_scale_factor = 1.0

        vim.o.winblend = 20
        vim.o.pumblend = 20

        -- Normal Ctrl+C and Ctrl+V
        vim.keymap.set("c", "<C-v>", "<C-V> <C-R>+")
        vim.keymap.set("v", "<C-c>", '"+y')
        vim.keymap.set("v", "<C-v>", '"+p<CR>')
        vim.keymap.set("v", "<C-x>", '"+d')
        vim.keymap.set("i", "<C-v>", "<C-R>+")
        -- Ctrl-Shift-C and Ctrl-Shift-V specifically for clipboard
        -- Only GUI allows double modifier keys
        vim.keymap.set("v", "<C-S-v>", '"+p<CR>')
        vim.keymap.set("v", "<C-S-c>", '"+y')
        vim.keymap.set("i", "<C-S-v>", "<C-R>+")
        vim.keymap.set("n", "<C-S-v>", '"+p<CR>')

        function Increase_font_size()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
        end

        function Decrease_font_size()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 0.9
        end

        function Toggle_animation()
            if vim.g.neovide_animation_length == 0 then
                vim.g.neovide_animation_length = 0.3
                vim.g.neovide_cursor_animate_command_line = true
                vim.g.neovide_scroll_animation_length = 0.1
                vim.g.neovide_position_animation_length = 0.15
                vim.g.neovide_cursor_animation_length = 0.06
                vim.print("Neovide animation enabled")
            else
                vim.g.neovide_animation_length = 0
                vim.g.neovide_cursor_animate_command_line = false
                vim.g.neovide_scroll_animation_length = 0
                vim.g.neovide_position_animation_length = 0
                vim.g.neovide_cursor_animation_length = 0
                vim.print("Neovide animation disabled")
            end
        end

        -- Set transparency and background color (title bar color)
        vim.g.neovide_transparency = 1
        -- Add keybinds to change transparency
        Change_transparency = function(delta)
            local new_t = vim.g.neovide_transparency + delta
            vim.g.neovide_transparency = math.min(1, math.max(0, new_t))
        end

        -- Add which-key mappings and submenu
        nor["G"] = {
            name = "GUI (Neovide)",
            i = { Increase_font_size, "Increase font size" },
            d = { Decrease_font_size, "Decrease font size" },
            o = {
                function()
                    vim.g.neovide_transparency = 1
                end,
                "Opaque window",
            },
            t = {
                function()
                    vim.g.neovide_transparency = 0.8
                end,
                "Transparent window (0.8)",
            },
            a = { Toggle_animation, "Toggle animation" },
        }
    else
        -- Assume QT
        vim.s.fontsize = 13

        local function reset_font()
            vim.o.guifont = "FiraCode Nerd Font:h" .. vim.s.fontsize
        end

        function Increase_font_size()
            vim.s.fontsize = vim.s.fontsize + 2
            reset_font()
        end

        function Decrease_font_size()
            vim.s.fontsize = vim.s.fontsize - 2
            reset_font()
        end
    end

    vim.keymap.set(
        { "n", "v", "i", "o" },
        "<C-ScrollWheelUp>",
        Increase_font_size
    )
    vim.keymap.set(
        { "n", "v", "i", "o" },
        "<C-ScrollWheelDown>",
        Decrease_font_size
    )
    vim.keymap.set({ "n", "v", "o" }, "<M-ScrollWheelUp>", function()
        Change_transparency(0.05)
    end)
    vim.keymap.set({ "n", "v", "o" }, "<M-ScrollWheelDown>", function()
        Change_transparency(-0.05)
    end)
end

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

-- Set wrap for markdown, html, xml and text; also remove Colorcolumn
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "html", "xml", "text", "abnf" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.colorcolumn = "121"
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
        etlconf = "json",
    },
})

-- .envrc is shell
vim.filetype.add({
    extension = {
        envrc = "bash",
    },
})

-- conf only if file starts with { and ends with }
-- TODO: use vim.filetype.add() instead
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.conf",
    callback = function()
        local line = vim.fn.getline(1)
        if line:find("^%s*{") then -- starts with {
            line = vim.fn.getline("$")
            if line:find("^%s*}") then -- ends with }
                vim.bo.filetype = "json"
            end
        end
    end,
})

-- EJS is HTML
vim.filetype.add({
    extension = {
        ejs = "html",
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
