-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
-- Windows specific settings
if string.find(wezterm.target_triple, "windows") then
    -- Color scheme
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
    COLORS = {
        tab_bg = "#20074a",
        tab_fg = "#a9b1d6",
        tab_bg_active = "#3b3052",
        tab_fg_active = "#ccccee",
    }
else
    -- Color scheme
    config.tab_bar_at_bottom = true
    TAB_SEP = wezterm.nerdfonts.ple_upper_left_triangle
    PRE_TAB_SEP = wezterm.nerdfonts.ple_upper_right_triangle

    -- Tab colors
    COLORS = {
        tab_bg = "#1c0738",
        tab_fg = "#a9b1d6",
        tab_bg_active = "#191a25",
        tab_fg_active = "#ccccee",
    }
end
COLORS["thumb"] = "#232433"

COLORS["cmd_bg"] = "#1a1b26"
COLORS["cmd_fg"] = "#a9b1d6"

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 40

-- Tab bar colors
config.colors = {
    tab_bar = {
        background = COLORS.tab_bg,
        new_tab = {
            bg_color = COLORS.tab_bg,
            fg_color = COLORS.tab_fg,
        },
        new_tab_hover = {
            bg_color = COLORS.tab_fg,
            fg_color = COLORS.tab_bg,
            italic = false,
        },
        inactive_tab_hover = {
            bg_color = COLORS.tab_bg,
            fg_color = COLORS.tab_fg,
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
            BG = COLORS.tab_bg_active
            FG = COLORS.tab_fg_active
            PC = (#panes > 1) and "[" .. #panes .. "] " or ""
        else
            BG = COLORS.tab_bg
            FG = COLORS.tab_fg
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
                    Color = tab.is_active and COLORS.tab_bg or BG,
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
            { Background = { Color = COLORS.tab_bg } },
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
config.colors.scrollbar_thumb = COLORS.thumb

-- Graphics acceleration
config.front_end = "WebGpu"

-- Command palette
config.command_palette_bg_color = COLORS.cmd_bg
config.command_palette_fg_color = COLORS.cmd_fg
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
            action = wezterm.action_callback(function(window, _, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
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

-- Admit to be WezTerm
config.term = "wezterm"

-- Inactive window style for non-Windows
if not string.find(wezterm.target_triple, "windows") then
    wezterm.on("window-focus-changed", function(window, _)
        local overrides = window:get_config_overrides() or {}
        if window:is_focused() then
            COLORS.tab_bg = "#1c0738"
        else
            COLORS.tab_bg = "#424242"
        end
        overrides.colors = {
            tab_bar = {
                background = COLORS.tab_bg,
                new_tab = {
                    bg_color = COLORS.tab_bg,
                    fg_color = COLORS.tab_fg,
                },
                new_tab_hover = {
                    bg_color = COLORS.tab_fg,
                    fg_color = COLORS.tab_bg,
                    italic = false,
                },
                inactive_tab_hover = {
                    bg_color = COLORS.tab_bg,
                    fg_color = COLORS.tab_fg,
                    italic = false,
                },
            },
        }
        window:set_config_overrides(overrides)
        -- Force redraw of tab bar
        wezterm.emit("format-tab-title")
    end)
end

wezterm.on("bell", function(window, pane)
    if window:is_focused() then
        -- No bell for focused windows
        return
    end
    local message = 'Bell in pane "' .. pane:get_title() .. '"'
    window:toast_notification("BEEP BOOP", message)
end)

config.custom_block_glyphs = false

-- and finally, return the configuration to wezterm
return config
