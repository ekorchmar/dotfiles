local COPILOT_ENABLED = os.getenv "DISABLE_COPILOT" == nil
local default_oil_columns = {
  "permissions",
  "size",
  "mtime",
  {
    "icon",
    default_file = require("astroui").get_icon "DefaultFile",
    directory = require("astroui").get_icon "FolderClosed",
  },
}
local oil_detail_view = true

---@type LazySpec
return {

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
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
          }, "\n"),
        },
      },
    },
  },
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    },
    config = function(_, opts)
      local transparent = require "transparent"
      transparent.setup(opts)
      transparent.clear_prefix "BufferLine"
      transparent.clear_prefix "NeoTree"
      transparent.clear_prefix "lualine"
    end,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.mappings.n["<Leader>ux"] = { "<Cmd>TransparentToggle<CR>", desc = "Toggle transparency" }
          if vim.tbl_get(opts, "autocmds", "heirline_colors") then
            table.insert(opts.autocmds.heirline_colors, {
              event = "User",
              pattern = "TransparentClear",
              desc = "Refresh heirline colors",
              callback = function()
                if package.loaded["heirline"] then require("astroui.status.heirline").refresh_colors() end
              end,
            })
          end
        end,
      },
    },
  },
  -- GitHub Copilot (if allowed)
  {
    "github/copilot.vim",
    cond = COPILOT_ENABLED,
    build = ":Copilot auth",
    config = function()
      vim.g.copilot_filetypes = { markdown = true }
      vim.g.copilot_no_tab_map = true
      -- Accept suggestions with Ctrl+a
      vim.keymap.set("i", "<C-a>", 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = COPILOT_ENABLED,
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
      {
        "AstroNvim/astrocore",
        opts = function(_, opts) opts.mappings.n["<Leader>@"] = { "<Cmd>CopilotChat<CR>", desc = "Copilot chat" } end,
      },
    },
    opts = {},
  },
  -- Neotree does not hijack the directory open
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = { hijack_netrw_behavior = "disabled" },
    },
  },
  -- Oil
  {
    "stevearc/oil.nvim",
    -- cmd = "Oil",
    lazy = false, -- May need to happen as a default file explorer
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>-"] = { function() require("oil").open() end, desc = "Open folder in Oil" },
            },
          },
          autocmds = {
            oil_settings = {
              {
                event = "FileType",
                desc = "Disable view saving for oil buffers",
                pattern = "oil",
                callback = function(args) vim.b[args.buf].view_activated = false end,
              },
              {
                event = "User",
                pattern = "OilActionsPost",
                desc = "Close buffers when files are deleted in Oil",
                callback = function(args)
                  if args.data.err then return end
                  for _, action in ipairs(args.data.actions) do
                    if action.type == "delete" then
                      local _, path = require("oil.util").parse_url(action.url)
                      local bufnr = vim.fn.bufnr(path)
                      if bufnr ~= -1 then require("astrocore.buffer").wipe(bufnr, true) end
                    end
                  end
                end,
              },
            },
          },
        },
      },
      {
        "rebelot/heirline.nvim",
        optional = true,
        dependencies = {
          "AstroNvim/astroui",
          opts = { status = { winbar = { enabled = { filetype = { "^oil$" } } } } },
        },
        opts = function(_, opts)
          if opts.winbar then
            local status = require "astroui.status"
            table.insert(opts.winbar, 1, {
              condition = function(self) return status.condition.buffer_matches({ filetype = "^oil$" }, self.bufnr) end,
              status.component.separated_path {
                padding = { left = 2 },
                max_depth = 0,
                suffix = false,
                path_func = function(self) return require("oil").get_current_dir(self.bufnr) end,
              },
            })
          end
        end,
      },
    },
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
      win_options = {
        signcolumn = "yes:2",
      },
      constrain_cursor = "name",
      keymaps = {
        ["gd"] = {
          desc = "Toggle file detail view",
          callback = function()
            oil_detail_view = not oil_detail_view
            if oil_detail_view then
              require("oil").set_columns(default_oil_columns)
            else
              require("oil").set_columns(default_oil_columns[4]) -- only icon
            end
          end,
        },
      },
      olumns = default_oil_columns,
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    ft = "oil",
    opts = {
      show_ignored = true, -- show files that match gitignore with !!
      symbols = { -- customize the symbols that appear in the git status columns
        index = {
          ["!"] = "",
          ["?"] = "",
          ["A"] = "",
          ["C"] = "",
          ["D"] = "",
          ["M"] = "",
          ["R"] = "",
          ["T"] = "",
          ["U"] = "",
        },
        working_tree = {
          ["!"] = "",
          ["?"] = "",
          ["A"] = "",
          ["C"] = "",
          ["D"] = "",
          ["M"] = "",
          ["R"] = "",
          ["T"] = "",
          ["U"] = "",
        },
      },
    },
  },
  -- Lorem ipsum generator
  {
    "derektata/lorem.nvim",
    config = function()
      require("lorem").opts {
        debounce_ms = 300, -- default debounce time in milliseconds
      }
    end,
  },
}
