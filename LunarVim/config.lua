vim.g.shiftwidth = 4
vim.wo.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99

lvim.plugins = {
  'github/copilot.vim',
  'tpope/vim-surround',
  'chrisbra/sudoedit.vim',
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>"},
    },
  },
  'anuvyklack/pretty-fold.nvim',
  'NvChad/nvim-colorizer.lua',
  'unblevable/quick-scope',
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  -- ABNF syntax
  {
    'vim-scripts/abnf',
    ft = 'abnf'
  },
}

-- I know how to use the mouse, thanks
vim.cmd.aunmenu{'PopUp.How-to\\ disable\\ mouse'}
vim.cmd.aunmenu{'PopUp.-1-' }


require('which-key').register({
  ['<leader>'] = {
    u = {  "<cmd>lua require('undotree').toggle()<cr>", 'Undo Tree' },
  }
})
local wkm = lvim.builtin.which_key.mappings
wkm["sd"] = { "<cmd>TodoTelescope<cr>", "TODO comments" }
wkm["t"] = {require("toggleterm").toggle, "Toggle Terminal"}

-- Folding
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

    function Increase_font_size()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
    end

    function Decrease_font_size()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 0.9
    end

    function Toggle_animation()
      if vim.g.neovide_animation_length == 0 then
        vim.g.neovide_animation_length = 0.3
      else
        vim.g.neovide_animation_length = 0
      end
    end

    -- Add which-key mappings and submenu
    wkm["G"] = {
      name = "GUI",
      i = { Increase_font_size, "Increase font size" },
      d = { Decrease_font_size, "Decrease font size" },
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
    {'n', 'v', 'i'},
    '<C-ScrollWheelUp>',
    Increase_font_size
  )
  vim.keymap.set(
    {'n', 'v', 'i'},
    '<C-ScrollWheelDown>',
    Decrease_font_size
  )
end


-- Copilot
vim.g.copilot_filetypes = { markdown = true }
vim.g.copilot_no_tab_map = true

-- Accept suggestions with Ctrl+a
vim.keymap.set('i', '<C-a>', 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = false
})

-- Colorizer
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

-- Colorcolumn to 80
vim.opt.colorcolumn = "80"

-- Set wrap for markdown, html, xml and text; also move Colorcolumn to 120
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown", "html", "xml", "text", "abnf"},
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.colorcolumn = "120"
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

-- Quick scope settings
vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

-- Filetypes:
-- ABNF
vim.filetype.add({
  extension = {
    abnf = 'abnf'
  }
})

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

-- Autocommands to set linenumber & signcolumn background for better contrast
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd([[
      highlight ColorColumn guibg=#13141b ctermbg=232
      highlight LineNr      guibg=#13141b ctermbg=232
      highlight SignColumn  guibg=#13141b ctermbg=232
      highlight GitSignsAdd     guibg=#13141b ctermbg=232
      highlight GitSignsChange  guibg=#13141b ctermbg=232
      highlight GitSignsDelete  guibg=#13141b ctermbg=232
    ]])
  end
})

