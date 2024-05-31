-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Tab bar
config.tab_bar_at_bottom = true
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 40

-- Font
config.font = wezterm.font("FiraCode Nerd Font")
config.adjust_window_size_when_changing_font_size = false
config.font_size = 14

-- Windows specific settings
if string.find(wezterm.target_triple, "windows") then
  -- Opacity
  -- Waiting for KDE blur support...
  config.window_background_opacity = 0.6
  config.win32_system_backdrop = 'Acrylic'
  config.default_prog = { 'pwsh', '-NoLogo' }
  -- Native decorations
  config.tab_bar_at_bottom = false
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
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
  -- Shift + arrows to switch tabs
  {
    key = 'LeftArrow',
    mods = 'SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'RightArrow',
    mods = 'SHIFT',
    action = wezterm.action.ActivateTabRelative(1),
  },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },

  -- and make CTRL-Click open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },

  -- Scrolling up while holding CTRL increases the font size
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },

  -- Scrolling down while holding CTRL decreases the font size
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
}

-- Nvim Zen Mode
wezterm.on('user-var-changed', function(window, pane, name, value)
      local overrides = window:get_config_overrides() or {}
      if name == "ZEN_MODE" then
          local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
              while (number_value > 0) do
                window:perform_action(wezterm.action.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            overrides.enable_tab_bar = false
        elseif number_value < 0 then
            window:perform_action(wezterm.action.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
        else
              overrides.font_size = number_value
              overrides.enable_tab_bar = false
          end
    end
      window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config
