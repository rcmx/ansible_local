
local wezterm = require 'wezterm'
local action = wezterm.action

local config = wezterm.config_builder()

config.leader = { key = 'a', mods = 'CTRL' }

--config.font = wezterm.font('Hack Nerd Font')
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 120
config.scrollback_lines = 9999
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

-- Key bindings
config.keys = {
    -- tabs
    {
        key = 'c',
        mods = 'LEADER',
        action = action.SpawnTab 'CurrentPaneDomain',
    },

    -- Pane navigation (vim-style)
    {
        key = 'h',
        mods = 'LEADER',
        action = action.ActivatePaneDirection 'Left',
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = action.ActivatePaneDirection 'Down',
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = action.ActivatePaneDirection 'Up',
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = action.ActivatePaneDirection 'Right',
    },

    -- Split panes
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '-',
        mods = 'LEADER',
        action = action.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- New window
    {
        key = 'n',
        mods = 'LEADER',
        action = action.SpawnWindow,
    },

    -- Last window (similar to C-^)
    {
        key = '6',
        mods = 'LEADER|CTRL',
        action = action.ActivateLastTab,
    },

    -- Pane resizing
    {
        key = 'UpArrow',
        mods = 'LEADER|CTRL',
        action = action.AdjustPaneSize { 'Up', 2 },
    },
    {
        key = 'DownArrow',
        mods = 'LEADER|CTRL',
        action = action.AdjustPaneSize { 'Down', 2 },
    },
    {
        key = 'LeftArrow',
        mods = 'LEADER|CTRL',
        action = action.AdjustPaneSize { 'Left', 2 },
    },
    {
        key = 'RightArrow',
        mods = 'LEADER|CTRL',
        action = action.AdjustPaneSize { 'Right', 2 },
    },
}

return config
