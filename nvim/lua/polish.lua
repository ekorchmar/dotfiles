if vim.g.vscode then return {} end

-- Personal preference
vim.g.autoformat = false
vim.opt.cmdheight = 2
vim.opt.colorcolumn = "81"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = true

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
    vim.opt_local.formatoptions:remove { "o" }
    -- Better formatting of paragraphs
    vim.opt_local.formatoptions:append { "n", "2" }
  end,
})

-- Set transparent background
--- Remember actual background to toggle back
local ACTUAL_BACKGROUND = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
--- Set up keybinding to toggle background
require("which-key").add {
  {
    "<leader>ux",
    function()
      if ACTUAL_BACKGROUND == nil then
        vim.notify("Can't toggle: colorscheme sets no background", vim.log.levels.WARN)
        return
      end

      local current_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      if current_bg == nil then
        -- Set background
        vim.notify("Toggling background on", vim.log.levels.INFO)
        vim.cmd("hi Normal guibg=#" .. string.format("%06x", ACTUAL_BACKGROUND) .. " ctermbg=NONE")
      else
        -- Set transparent
        vim.notify("Toggling background off", vim.log.levels.INFO)
        vim.cmd "hi Normal guibg=NONE ctermbg=NONE"
      end
    end,
    desc = "Toggle background transparency",
  },
}
--- Update remembered background on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local should_set_transparent = vim.api.nvim_get_hl(0, { name = "Normal" }).bg == nil

    ACTUAL_BACKGROUND = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

    if should_set_transparent then vim.cmd "hi Normal guibg=NONE ctermbg=NONE" end
  end,
})
--- Default to transparent background on startup
vim.cmd "hi Normal guibg=NONE ctermbg=NONE"
