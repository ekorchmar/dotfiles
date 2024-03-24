-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

vim.g.shiftwidth = 4
vim.wo.relativenumber = true

lvim.plugins = {
  'github/copilot.vim',
  'tpope/vim-surround',
  'chrisbra/sudoedit.vim',
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },
  'anuvyklack/pretty-fold.nvim',
  'norcalli/nvim-colorizer.lua'
}

-- I know how to use the mouse, thanks
vim.cmd.aunmenu{'PopUp.How-to\\ disable\\ mouse'}
vim.cmd.aunmenu{'PopUp.-1-' }


require('which-key').register({
  ['<leader>'] = {
    u = { '<cmd>lua require("undotree").toggle()<cr>', 'Undo Tree' },
    t = { '<cmd>lua require("toggleterm").toggle()<cr>', 'Toggle Terminal' },
  }
})

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
    -- Same but with Ctrl+Shift
    vim.keymap.set('c', '<C-S-v>', '<C-V> <C-R>+')
    vim.keymap.set('v', '<C-S-c>', '"+y')
    vim.keymap.set('v', '<C-S-v>', '"+p<CR>')
    vim.keymap.set('v', '<C-S-x>', '"+d')
    vim.keymap.set('i', '<C-S-v>', '<C-R>+')

    function Increase_font_size()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
    end

    function Decrease_font_size()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 0.9
    end
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

vim.keymap.set('i', '<C-y>', 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = false
})

-- Colorizer
require('colorizer').setup()

-- Toggleterm
vim.keymap.set({'v', 'n'}, '<leader>t', '<cmd>lua require("toggleterm").toggle()<cr>')

-- Windows specific
if vim.loop.os_uname().sysname == "Windows" then

  -- Enable powershell as your default shell
  vim.opt.shell = "pwsh.exe -NoLogo"
  vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
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

