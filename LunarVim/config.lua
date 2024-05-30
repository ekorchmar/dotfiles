vim.opt.cmdheight = 2
vim.g.shiftwidth = 4
vim.wo.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.o.autochdir = true
vim.opt.colorcolumn = "81"
-- Listchars
vim.opt.list = true
vim.opt.listchars = {
  tab = '>-',
  eol = '⤶',
  -- space = '⋅', -- A lot of clutter; TODO: highlight leading spaces only
  trail = '•',
  extends = '◀',
  precedes = '▶',
}
vim.opt.showbreak = '↪'
vim.opt.virtualedit = 'block,onemore'


lvim.plugins = {
  {
    'github/copilot.vim',
    build = ':Copilot auth',
  },
  'tpope/vim-surround',
  {
    'chrisbra/sudoedit.vim',
    cmd = 'SudoWrite',
  },
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>"},
    },
  },
  {
    'anuvyklack/pretty-fold.nvim',
    event = "BufRead",
    config = function()
    require('pretty-fold').setup{
      keep_indentation = false,
      fill_char = '━',
      sections = {
        left = {
         '━ ', function() return string.rep('>', vim.v.foldlevel) end, ' ━┫',
         'content', '┣━━━┫ ', 'number_of_folded_lines', ' ┣━',
        },
        right = {}
      }
    }
    end,
  },
  {
    'NvChad/nvim-colorizer.lua',
    event = "BufRead",
    config = function()
      require('colorizer').setup {
        filetypes = {
          '*';
          css = { rgb_fn = true; };
          scss = { rgb_fn = true; };
          html = { rgb_fn = true; };
        },
        user_default_options = {
          names = false;
        }
      }
    end,
  },
  {
    'unblevable/quick-scope',
    keys = { 'f', 'F', 't', 'T' },
  },
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
    'vim-scripts/abnf',
    ft = 'abnf'
  },
  'tpope/vim-repeat',
  {
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('render-markdown').setup({
        headings = {
          '󰲡 ',
          '#󰲣 ',
          '##󰲥 ',
          '###󰲧 ',
          '####󰲩 ',
          '#####󰲫 ',
        },
        -- Disable heading coloring
        highlights = { heading = {
          backgrounds = { },
          foregrounds = { '@punctuation.special.markdown' },
        } },
      })
    end,
    ft = 'markdown'
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup {
        columns = { "icon", "permissions", "size", "mtime" },
        view_options = {
          show_hidden = true,
        },
        constrain_cursor = "name",
      }
    end,
  },
  {
    -- Breaks markdown rendering which links some hl to colorcolumn
    enabled = false,
    'Bekaboo/deadcolumn.nvim',
    event = "BufRead",
    config = function()
      require('deadcolumn').setup({
        modes = function(_)
          return true
        end,
        blending = {
          hlgroup = { 'SignColumn', 'bg' },
        },
      })
    end,
  },
  {
    '2KAbhishek/nerdy.nvim',
    dependencies = { 'stevearc/dressing.nvim' },
  },
  {
    'petertriho/nvim-scrollbar',
    cond = function()
      return vim.fn.exists('g:neovide') ~= 1
    end, -- Neovide is glitchy
    dependencies = { "lewis6991/gitsigns.nvim" },
    event = "BufRead",
    config = function()
      require("scrollbar").setup({
        show_in_active_only = true,
        hide_if_all_visible = true,
      })
      require("scrollbar.handlers.gitsigns").setup()
    end
  },
  {
    'bennypowers/nvim-regexplainer',
    event = "BufRead",
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('regexplainer').setup({
        auto = true,
      })
    end,
  },
  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
  },
  {
    'nanotee/zoxide.vim',
    dependencies = { 'junegunn/fzf.vim' },
    cmd = {
      'Cd', 'Cdi',
      'Jcd', 'Jcdi',
      'Lcd', 'Lcdi',
      'Tcd', 'Tcdi',
    },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = {
      "folke/twilight.nvim",
    },
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.6,
        width = function ()
          local wide = { markdown = true, html = true,
                         text = true, abnf = true }
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
        wezterm = { enabled = true },
      },
      on_open = function()
        -- Currently broken:
        -- https://github.com/nvim-lualine/lualine.nvim/issues/1066
        require("lualine").hide()
        vim.opt.laststatus = 0
        vim.opt.cmdheight = 0

        -- Get the lines of current window
        local lines = vim.api.nvim_win_get_height(0)

        local wins = vim.api.nvim_list_wins()
        local bg_window = wins[#wins]
        local zen_window = wins[#wins - 1]

        -- Offset the windows to fill space of cmd and status line
        vim.api.nvim_win_set_height(bg_window, lines + 4)
        vim.api.nvim_win_set_height(zen_window, lines + 4)
      end,
      on_close = function()
        require("lualine").hide { unhide = true }
        vim.opt.cmdheight = 2
      end,
    },
  },
  {
    "folke/twilight.nvim",
    lazy = true,
    opts = { context = 14 }
  }
}

-- I know how to use the mouse, thanks
vim.cmd.aunmenu{'PopUp.How-to\\ disable\\ mouse'}
vim.cmd.aunmenu{'PopUp.-1-' }

-- Override Lazygit command
lvim.builtin.terminal.size = 120
local function toggle_lazygit()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "vertical",
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  lazygit:toggle()
end


local wkm = lvim.builtin.which_key.mappings
wkm["bq"] = { "<cmd>bd<cr>", "Close current buffer" }
wkm["gg"] = { toggle_lazygit, "Lazygit" }
wkm["sd"] = { "<cmd>TodoTelescope<cr>", "TODO comments" }
wkm["sn"] = {
  function()
    local telescope = require("telescope")
    if not telescope.extensions.nerdy then
      telescope.load_extension("nerdy")
    end
    vim.cmd("Nerdy")
  end,
 "Nerd font symbols" }
wkm["t"] = {"<cmd>ToggleTerm direction=vertical size=80<cr>","Split terminal"}
wkm["u"] = {"<cmd>lua require('undotree').toggle()<cr>", "Undo Tree"}
wkm["z"] = {"<cmd>ZenMode<cr>", "Zen mode"}
wkm["-"] = {"<cmd>Oil<cr>", "Oil the directory"}
-- Remove unneeded and duplicating menus
wkm["c"] = {}
wkm["f"] = {}
wkm["p"] = {}
wkm["q"] = {}
wkm["w"] = {}
wkm["T"] = {}

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
if vim.fn.has('gui_running') then
  vim.cmd('set guifont=FiraCode\\ Nerd\\ Font:h13')

  if vim.fn.exists('g:neovide') then
    vim.g.neovide_hide_mouse_when_typing = 1
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_scroll_animation_length = 0.1
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_scale_factor = 1.0

    vim.o.winblend = 20
    vim.o.pumblend = 20

    -- Normal Ctrl+C and Ctrl+V
    vim.keymap.set('c', '<C-v>', '<C-V> <C-R>+')
    vim.keymap.set('v', '<C-c>', '"+y')
    vim.keymap.set('v', '<C-v>', '"+p<CR>')
    vim.keymap.set('v', '<C-x>', '"+d')
    vim.keymap.set('i', '<C-v>', '<C-R>+')
    -- Ctrl-Shift-C and Ctrl-Shift-V specifically for clipboard
    -- Only GUI allows double modifier keys
    vim.keymap.set('v', '<C-S-v>', '"+p<CR>')
    vim.keymap.set('v', '<C-S-c>', '"+y')
    vim.keymap.set('i', '<C-S-v>', '<C-R>+')
    vim.keymap.set('n', '<C-S-v>', '"+p<CR>')

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
        vim.print("Neovide animation enabled")
      else
        vim.g.neovide_animation_length = 0
        vim.g.neovide_cursor_animate_command_line = false
        vim.g.neovide_scroll_animation_length = 0
        vim.g.neovide_position_animation_length = 0
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
    wkm["G"] = {
      name = "GUI (Neovide)",
      i = { Increase_font_size, "Increase font size" },
      d = { Decrease_font_size, "Decrease font size" },
      o = { function ()
        vim.g.neovide_transparency = 1
      end, "Opaque window" },
      t = { function ()
        vim.g.neovide_transparency = 0.8
      end, "Transparent window (0.8)" },
      a = { Toggle_animation, "Toggle animation" },
    }
  else
    -- Assume QT
    vim.s.fontsize = 13

    local function reset_font()
      vim.o.guifont = 'FiraCode Nerd Font:h' .. vim.s.fontsize
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
    {'n', 'v', 'i', 'o'},
    '<C-ScrollWheelUp>',
    Increase_font_size
  )
  vim.keymap.set(
    {'n', 'v', 'i', 'o'},
    '<C-ScrollWheelDown>',
    Decrease_font_size
  )
  vim.keymap.set({ "n", "v", "o" }, "<M-ScrollWheelUp>", function()
    Change_transparency(0.05)
  end)
  vim.keymap.set({ "n", "v", "o" }, "<M-ScrollWheelDown>", function()
    Change_transparency(-0.05)
  end)
end


-- Copilot
vim.g.copilot_filetypes = { markdown = true }
vim.g.copilot_no_tab_map = true
-- Accept suggestions with Ctrl+a
vim.keymap.set('i', '<C-a>', 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = false
})

-- Windows specific
if vim.loop.os_uname().sysname == "Windows_NT" then

  -- Enable powershell as your default shell
  vim.opt.shell = "pwsh.exe -NoLogo"
  vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::" ..
    "InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.cmd [[
      let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
      let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
      set shellquote= shellxquote=
    ]]

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
  pattern = {"markdown", "html", "xml", "text", "abnf"},
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.colorcolumn = ""
  end
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
vim.g.surround_97 = "<a href=\"\r\"></a>"
-- "A" for anchor (puts text inside tag)
vim.g.surround_65 = "<a href=\"\">\r</a>"
-- "i" for image (puts text in src)
vim.g.surround_105 = "<img src=\"\r\">"
-- "P" for Python """ multiline string/Docstring
vim.g.surround_80 = "\"\"\"\n\r\n\"\"\""
-- "Q" for Qlik set selector
vim.g.surround_81 = "{< \r; >}"

-- Quick scope settings
vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

-- Filetypes:
-- ABNF
vim.filetype.add({
  extension = {
    abnf = 'abnf'
  }
})

-- Check if JSON for .conf and .etlconf
vim.filetype.add({
  extension = {
    etlconf = 'json'
  }
})

-- conf only if file starts with { and ends with }
-- TODO: use vim.filetype.add() instead
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.conf",
  callback = function()
    local line = vim.fn.getline(1)
    if line:find('^%s*{') then -- starts with {
      line = vim.fn.getline('$')
      if line:find('^%s*}') then -- ends with }
        vim.bo.filetype = 'json'
      end
    end
  end
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
  end
})

-- Zoxide
vim.g.zoxide_prefix = 'cd'
vim.g.zoxide_uses_select = 1

-- Set the terminal to override ANSI colors (lunar color scheme does not)
-- The OG eight
vim.g.terminal_color_0 = '#2a2b3d' -- Black
vim.g.terminal_color_1 = '#f7768e' -- Red
vim.g.terminal_color_2 = '#9ece6a' -- Green
vim.g.terminal_color_3 = '#e0af68' -- Yellow
vim.g.terminal_color_4 = '#7aa2f7' -- Blue
vim.g.terminal_color_5 = '#ad8ee6' -- Magenta
vim.g.terminal_color_6 = '#7dcfff' -- Cyan
vim.g.terminal_color_7 = '#787c99' -- White
-- The bright bunch
vim.g.terminal_color_8 = '#3b3d57' -- Black
vim.g.terminal_color_9 = '#ff7a95' -- Red
vim.g.terminal_color_10 = '#afe274' -- Green
vim.g.terminal_color_11 = '#f4bd71' -- Yellow
vim.g.terminal_color_12 = '#7ea9ff' -- Blue
vim.g.terminal_color_13 = '#bc9afa' -- Magenta
vim.g.terminal_color_14 = '#91d7ff' -- Cyan
vim.g.terminal_color_15 = '#888dad' -- White

