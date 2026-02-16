-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

DARK_COLOR_SCHEME = "Catppuccin Mocha"
LIGHT_COLOR_SCHEME = "Catppuccin Latte"
local TABS_AT_BOTTOM = true

-- This will hold the configuration.
local config = wezterm.config_builder()

local function set_ui()
    -- Colors
    config.color_scheme = DARK_COLOR_SCHEME

    config.command_palette_bg_color = "black"
    config.command_palette_fg_color = "lightgray"

    config.window_decorations = "TITLE | RESIZE"
    config.window_background_opacity = 0.8

    --Platform-specific settings
    if string.find(wezterm.target_triple, "windows") then
        -- Opacity
        -- config.text_background_opacity = 0.8
        config.win32_system_backdrop = "Acrylic"
        config.default_prog = { "pwsh", "-NoLogo" }

        -- Replace native decorations
        TABS_AT_BOTTOM = false
        config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

        -- Disable SSH interception
        config.mux_enable_ssh_agent = false

        -- Add git bash to the launch menu
        config.launch_menu = {
            {
                label = "Git Bash",
                args = { "C:\\Program Files\\Git\\bin\\bash.exe" },
            },
        }
    elseif string.find(wezterm.target_triple, "darwin") then
        config.macos_window_background_blur = 20
    else -- Linux
        config.kde_window_background_blur = true
    end

    -- Bell notification
    -- Disable audio
    config.audible_bell = "Disabled"
    -- Flash the pane
    config.visual_bell = {
        fade_in_function = "EaseIn",
        fade_in_duration_ms = 150,
        fade_out_function = "EaseOut",
        fade_out_duration_ms = 150,
    }
    config.colors.visual_bell = "#202020"

    -- Window padding
    config.window_padding = {
        left = ".5cell",
        right = 0,
        top = 0,
        bottom = 0,
    }

    -- Tab bar
    config.enable_tab_bar = true
    config.tab_bar_at_bottom = TABS_AT_BOTTOM
    config.hide_tab_bar_if_only_one_tab = false
    config.tab_max_width = 40

    -- Font
    config.font = wezterm.font("FiraCode Nerd Font")
    config.adjust_window_size_when_changing_font_size = false
    config.font_size = 14

    -- Graphics acceleration
    config.front_end = "WebGpu"

    config.command_palette_rows = 8
    config.command_palette_font_size = 16
end

-- Function to format tab name
local function no_default(name, tab)
    -- Use any custom name
    if name ~= "default" then
        return name
    end

    -- get the foreground process name if available
    local process_name
    if tab.active_pane and tab.active_pane.foreground_process_name then
        process_name = tab.active_pane.foreground_process_name
        process_name = process_name:match("([^/\\]+)[/\\]?$") or process_name
    end

    if process_name == "" or process_name == "wslhost.exe" then
        process_name = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title
            or tab.active_pane.title
    end

    -- if the tab active pane contains a non-local domain, use the domain name
    if process_name == "wezterm" then
        process_name = tab.active_pane.domain_name ~= "local"
                and tab.active_pane.domain_name
            or "wezterm"
    end

    -- If process name ends with .exe, remove it
    process_name = process_name:gsub("%.exe$", "")

    return process_name
end

-- Apply the tabline
local tabline =
    wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        section_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_upper_right_triangle,
        },
        tab_separators = {
            left = TABS_AT_BOTTOM and wezterm.nerdfonts.ple_upper_left_triangle
                or wezterm.nerdfonts.ple_lower_left_triangle,
            right = TABS_AT_BOTTOM
                    and wezterm.nerdfonts.ple_upper_right_triangle
                or wezterm.nerdfonts.ple_upper_right_triangle,
        },
    },
    sections = {
        tabline_a = { "mode" },
        tabline_b = {},
        tabline_c = {},
        tab_active = {
            { "index", padding = 0 },
            {
                "process",
                padding = { left = 1, right = 0 },
                icons_only = true,
            },
            {
                "tab",
                padding = { left = 0, right = 0 },
                icons_enabled = false,
                fmt = no_default,
            },
        },
        tab_inactive = {
            { "index", padding = 0 },
            {
                "process",
                padding = { left = 1, right = 0 },
                icons_only = true,
            },
            {
                "tab",
                padding = { left = 0, right = 0 },
                icons_enabled = false,
                fmt = no_default,
            },
        },
        tabline_x = { "ram" },
        tabline_y = { "cpu" },
        tabline_z = { "domain" },
    },
})

tabline.apply_to_config(config)

local function set_controls()
    -- Key bindings
    config.disable_default_key_bindings = true
    config.keys = {
        -- Ctrl+Shift+brackets for V and H split
        {
            key = "(",
            mods = "CTRL|SHIFT",
            action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
        },
        {
            key = ")",
            mods = "CTRL|SHIFT",
            action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
        },
        -- Shift + arrows to switch tabs
        {
            key = "LeftArrow",
            mods = "SHIFT",
            action = act.ActivateTabRelative(-1),
        },
        {
            key = "RightArrow",
            mods = "SHIFT",
            action = act.ActivateTabRelative(1),
        },
        -- Ctrl + Tab to switch panes
        {
            key = "Tab",
            mods = "CTRL",
            action = act.ActivatePaneDirection("Next"),
        },
        {
            key = "Tab",
            mods = "CTRL|SHIFT",
            action = act.ActivatePaneDirection("Prev"),
        },
        -- Ctrl + Shift + F to search
        {
            key = "f",
            mods = "CTRL|SHIFT",
            action = act.Search("CurrentSelectionOrEmptyString"),
        },
        -- Ctrl + Shift + arrows to move tabs
        {
            key = "LeftArrow",
            mods = "CTRL|SHIFT",
            action = act.MoveTabRelative(-1),
        },
        {
            key = "RightArrow",
            mods = "CTRL|SHIFT",
            action = act.MoveTabRelative(1),
        },
        -- Ctrl + Shift + C to copy, V to paste
        {
            key = "c",
            mods = "CTRL|SHIFT",
            action = act.CopyTo("Clipboard"),
        },
        {
            key = "v",
            mods = "CTRL|SHIFT",
            action = act.PasteFrom("Clipboard"),
        },
        -- Ctrl + Shift + T to open a new tab
        {
            key = "t",
            mods = "CTRL|SHIFT",
            action = act.SpawnTab("DefaultDomain"),
        },
        -- Ctrl + Shift + X to enter copy mode
        {
            key = "x",
            mods = "CTRL|SHIFT",
            action = act.ActivateCopyMode,
        },
        -- Ctrl + Shift + Z to open a new tab with menu
        {
            key = "z",
            mods = "CTRL|SHIFT",
            action = act.ShowLauncher,
        },
        -- Ctrl + Shift + P for command palette
        {
            key = "p",
            mods = "CTRL|SHIFT",
            action = act.ActivateCommandPalette,
        },
        -- Ctrl + Shift + W to close tab without confirmation
        {
            key = "w",
            mods = "CTRL|SHIFT",
            action = act.CloseCurrentTab({ confirm = false }),
        },
        -- Ctrl + Shift + N to open a new window
        {
            key = "n",
            mods = "SHIFT|CTRL",
            action = act.SpawnWindow,
        },
        -- Ctrl + Alt + F to toggle fullscreen
        {
            key = "f",
            mods = "CTRL|ALT",
            action = act.ToggleFullScreen,
        },
        -- Ctrl + Shift + K to send ^L and clear the screen
        {
            key = "k",
            mods = "CTRL|SHIFT",
            action = act.Multiple({
                act.SendKey({ key = "L", mods = "CTRL" }),
                act.ClearScrollback("ScrollbackAndViewport"),
            }),
        },
        -- Ctrl + Shift + Ä to increase font size
        {
            key = "Ä",
            mods = "CTRL|SHIFT",
            action = act.IncreaseFontSize,
        },
        -- Ctrl + Shift + Ö to decrease font size
        {
            key = "Ö",
            mods = "CTRL|SHIFT",
            action = act.DecreaseFontSize,
        },
        -- Ctrl + Shift + Ü to reset font size
        {
            key = "Ü",
            mods = "CTRL|SHIFT",
            action = act.ResetFontSize,
        },
        -- Ctrl + Shift + Q to enter pane selection mode
        {
            key = "Q",
            mods = "CTRL|SHIFT",
            action = act.PaneSelect({
                alphabet = "qwertz",
            }),
        },
        -- Ctrl + Shift + Space to detach pane into a new window
        {
            key = "Space",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(_, pane)
                _ = pane:move_to_new_window()
            end),
        },
        -- Ctrl + Shift + R to rename the tab
        {
            key = "R",
            mods = "CTRL|SHIFT",
            action = act.PromptInputLine({
                description = wezterm.format({
                    { Attribute = { Intensity = "Bold" } },
                    { Foreground = { AnsiColor = "Fuchsia" } },
                    { Text = "Enter new name for this tab:" },
                }),
                -- initial_value = "Tab: ",
                action = wezterm.action_callback(function(window, _, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },
        -- Ctrl + Shift + O to start REPL
        {
            key = "O",
            mods = "CTRL|SHIFT",
            action = act.ShowDebugOverlay,
        },
        -- Shift + PgDown / PgUp to scroll down / up
        { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
        { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },

        -- Alt + Shift + A to toggle light/dark mode
        {
            key = "A",
            mods = "ALT|SHIFT",
            action = wezterm.action_callback(function(window, _)
                local overrides = window:get_config_overrides() or {}
                if overrides.color_scheme == nil then
                    overrides.color_scheme = LIGHT_COLOR_SCHEME
                else
                    overrides.color_scheme = nil
                end
                window:set_config_overrides(overrides)
            end),
        },
        -- Ctrl + Shift + "+" to increase zoom
        {
            key = "+",
            mods = "CTRL|SHIFT",
            action = act.IncreaseFontSize,
        },
        {
            key = "*", -- Shifted "+" on de_DE
            mods = "CTRL|SHIFT",
            action = act.IncreaseFontSize,
        },
        -- Ctrl + Shift + "-" to decrease zoom
        {
            key = "-",
            mods = "CTRL|SHIFT",
            action = act.DecreaseFontSize,
        },
        {
            key = "_", -- Shifted "-" on de_DE
            mods = "CTRL|SHIFT",
            action = act.DecreaseFontSize,
        },
        -- Ctrl + Shift + 0 to reset zoom
        {
            key = "=", -- Shifted "0" on de_DE
            mods = "CTRL|SHIFT",
            action = act.ResetFontSize,
        },
    }
    -- Alt + number for corresponding tab
    for i = 1, 9 do
        table.insert(config.keys, {
            key = tostring(i),
            mods = "ALT",
            action = act.ActivateTab(i - 1),
        })
    end

    -- Mouse bindings
    config.mouse_bindings = {
        -- Change the default click behavior so that it only selects
        -- text and doesn't open hyperlinks
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = act.CompleteSelection("ClipboardAndPrimarySelection"),
        },

        -- and make CTRL-Click open hyperlinks
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },

        -- Scrolling up while holding CTRL increases the font size
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = "CTRL",
            action = act.IncreaseFontSize,
        },

        -- Scrolling down while holding CTRL decreases the font size
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = "CTRL",
            action = act.DecreaseFontSize,
        },
    }
end

-- Nvim Zen Mode
ZEN_FORCED_FULLSCREEN = nil
local function zen_enter(window, pane, overrides)
    window:toast_notification(
        "Zen Mode",
        "Zen mode activated by " .. pane:get_foreground_process_name(),
        nil,
        3000
    )

    local fullscreen_before_zen = window:get_dimensions().is_full_screen
    if not fullscreen_before_zen then
        window:perform_action(act.ToggleFullScreen, pane)
    end
    overrides.enable_tab_bar = false

    ZEN_FORCED_FULLSCREEN = not fullscreen_before_zen
end

wezterm.on("user-var-changed", function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "ZEN_MODE" then
        local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
            -- Enabled with incremental font size
            while number_value > 0 do
                window:perform_action(act.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            zen_enter(window, pane, overrides)
        elseif number_value < 0 then
            -- Disabled, reset font size
            window:perform_action(act.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
            if
                ZEN_FORCED_FULLSCREEN and window:get_dimensions().is_full_screen
            then
                window:perform_action(act.ToggleFullScreen, pane)
            end
            ZEN_FORCED_FULLSCREEN = nil
        else
            -- Enabled with specific font size
            overrides.font_size = number_value
            zen_enter(window, pane, overrides)
        end
    end
    window:set_config_overrides(overrides)
end)

wezterm.on("bell", function(window, pane)
    if not pane:has_unseen_output() then
        -- No bell for focused windows
        return
    end
    local tab = pane:tab()
    local message = "Tab "
        .. tab:tab_id()
        .. ": "
        .. (pane:get_foreground_process_name() or "Unknown")
    window:toast_notification("Bell in unfocused pane", message, nil, 5000)
end)

-- Smart splits with neovim
-- Need to be here after the key bindings
local smart_splits =
    wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config)

-- Return the configuration to wezterm
set_ui()
set_controls()

return config
