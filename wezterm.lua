-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Tab bar
config.tab_bar_at_bottom = true
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 16

-- Font
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 14

-- Opacity
-- Waiting for KDE blur support...
if wezterm.target_triple.find("windows") then
  config.window_background_opacity = 0.6
  config.win32_system_backdrop = 'Acrylic'
end

-- Key bindings
config.keys = {
  -- Ctrl+Shift+brackets for V and H split
  {
    key = '(',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = ')',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
}

-- and finally, return the configuration to wezterm
return config
