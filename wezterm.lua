-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Windows specific settings
if string.find(wezterm.target_triple, "windows") then
    -- Color scheme
    config.color_scheme = "Tokyo Night"
    -- Opacity
    -- Waiting for KDE blur support...
    config.window_background_opacity = 0.6
    config.win32_system_backdrop = "Acrylic"
    config.default_prog = { "pwsh", "-NoLogo" }
    -- Native decorations
    config.tab_bar_at_bottom = false
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
    TAB_SEP = wezterm.nerdfonts.ple_lower_left_triangle
    PRE_TAB_SEP = wezterm.nerdfonts.ple_lower_right_triangle

    -- Tab colors
    TAB_BAR_BG_COLOR = "#20074a"
    TAB_BAR_FG_COLOR = "#a9b1d6"
    TAB_BG_COLOR_ACTIVE = "#3b3052"
    TAB_FG_COLOR_ACTIVE = "#ccccee"
else
    -- Color scheme
    config.color_scheme = "Purple Rain"
    config.tab_bar_at_bottom = true
    TAB_SEP = wezterm.nerdfonts.ple_upper_left_triangle
    PRE_TAB_SEP = wezterm.nerdfonts.ple_upper_right_triangle

    -- Tab colors
    TAB_BAR_BG_COLOR = "#1c0738"
    TAB_BAR_FG_COLOR = "#a9b1d6"
    TAB_BG_COLOR_ACTIVE = "#20074a"
    TAB_FG_COLOR_ACTIVE = "#ccccee"
end
SCROLLBAR_THUMB_COLOR = "#232433"

COMMAND_BG_COLOR = "#1a1b26"
COMMAND_FG_COLOR = "#a9b1d6"


-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 40

-- Tab bar colors
config.colors = {
    tab_bar = {
        background = TAB_BAR_BG_COLOR,
        new_tab = {
            bg_color = TAB_BAR_BG_COLOR,
            fg_color = TAB_BAR_FG_COLOR,
        },
        new_tab_hover = {
            bg_color = TAB_BAR_FG_COLOR,
            fg_color = TAB_BAR_BG_COLOR,
            italic = false,
        },
        inactive_tab_hover = {
            bg_color = TAB_BAR_BG_COLOR,
            fg_color = TAB_BAR_FG_COLOR,
            italic = false,
        },
    },
}

-- Tab title formatting
local function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if not title or #title == 0 then
        title = tab_info.active_pane.title
    end

    -- Remove .exe from the end
    if string.find(wezterm.target_triple, "windows") then
        title = title:gsub("%.[eE][xX][eE]$", "")
    end

    return title
end

wezterm.on(
    "format-tab-title",
    function(tab, tabs, panes, config_, hover, max_width)
        _ = { config_, max_width }

        -- Get next tab
        NEXT_TAB = nil
        for _, t in ipairs(tabs) do
            if t.tab_index == tab.tab_index + 1 then
                NEXT_TAB = t
                break
            end
        end

        local title = tab_title(tab)
        if tab.is_active then
            BG = TAB_BG_COLOR_ACTIVE
            FG = TAB_FG_COLOR_ACTIVE
            PC = (#panes > 1) and "[" .. #panes .. "] " or ""
        else
            BG = TAB_BAR_BG_COLOR
            FG = TAB_BAR_FG_COLOR
            PC = ""
        end

        -- Truncate title if it's too long
        if #title > 20 then
            title = title:sub(1, 19) .. "…"
        end

        return {
            { Attribute = { Italic = false } },
            { Attribute = { Intensity = hover and "Bold" or "Normal" } },
            -- Draw a pre-tab separator for active and first tabs
            {
                Background = {
                    Color = tab.is_active and TAB_BAR_BG_COLOR or BG,
                },
            },
            { Foreground = { Color = BG } },
            {
                Text = (tab.is_active or tab.tab_index == 0) and PRE_TAB_SEP
                    or "",
            },
            -- Draw number and title
            { Background = { Color = BG } },
            { Foreground = { Color = FG } },
            { Text = (tab.tab_index + 1) .. " " .. title },
            -- Pane count
            { Text = PC },
            { Background = { Color = TAB_BAR_BG_COLOR } },
            { Foreground = { Color = BG } },
            -- Draw end separator only if the next tab is not active
            {
                Text = NEXT_TAB and (not NEXT_TAB.is_active and TAB_SEP or "")
                    or TAB_SEP,
            },
        }
    end
)

-- Font
config.font = wezterm.font("FiraCode Nerd Font")
config.adjust_window_size_when_changing_font_size = false
config.font_size = 14

-- Scroll bar
config.enable_scroll_bar = true
config.colors.scrollbar_thumb = SCROLLBAR_THUMB_COLOR

-- Graphics acceleration
config.front_end = "WebGpu"

-- Command palette
config.command_palette_bg_color = COMMAND_BG_COLOR
config.command_palette_fg_color = COMMAND_FG_COLOR
config.command_palette_rows = 8
config.command_palette_font_size = 16

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
        action = act.PaneSelect {
            alphabet="qwertz"
        }
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

-- Nvim Zen Mode
FULLSCREEN_BEFORE_ZEN = false
wezterm.on("user-var-changed", function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "ZEN_MODE" then
        local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
            while number_value > 0 do
                window:perform_action(act.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            overrides.enable_tab_bar = false
            FULLSCREEN_BEFORE_ZEN = window:get_dimensions().is_full_screen
            if not FULLSCREEN_BEFORE_ZEN then
                window:perform_action(act.ToggleFullScreen, pane)
            end
        elseif number_value < 0 then
            window:perform_action(act.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
            if not FULLSCREEN_BEFORE_ZEN then
                window:perform_action(act.ToggleFullScreen, pane)
            end
        else
            overrides.font_size = number_value
            overrides.enable_tab_bar = false
        end
    end
    window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config
