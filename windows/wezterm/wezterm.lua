-- WezTerm: 1 tab = left claude / right nvim, running in the WSL room (room-myenv).
-- Linked to %USERPROFILE%\.config\wezterm\wezterm.lua by manifests\links.map.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- WSL domain: the shared room (user "ai", no /mnt/c, no Windows interop).
-- Area name: env var WEZTERM_ROOM_AREA (default "myenv") -> distribution room-<Area>.
local AREA = os.getenv('WEZTERM_ROOM_AREA') or 'myenv'
local ROOM = 'WSL:room-' .. AREA
config.wsl_domains = {
  { name = ROOM, distribution = 'room-' .. AREA, username = 'ai', default_cwd = '~' },
}
config.default_domain = ROOM
-- Do not pass Windows env (WSLENV with /p paths) into the room (see room.py wsl_env).
config.set_environment_variables = { WSLENV = '' }

-- Look
config.font = wezterm.font_with_fallback { 'PlemolJP Console NF', 'Cascadia Mono', 'Consolas' }
config.font_size = 11.0
config.color_scheme = 'Gruvbox Dark (Gogh)'
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'

-- Open a tab laid out as: left = claude, right = nvim.
local function new_session_tab(window)
  local tab, left, _ = window:mux_window():spawn_tab {}
  local right = left:split { direction = 'Right', size = 0.5 }
  left:send_text 'claude\n'
  right:send_text 'nvim\n'
  left:activate()
  return tab
end

wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  new_session_tab(window:gui_window())
  -- close the plain first tab that spawn_window created
  window:tabs()[1]:active_pane():send_text 'exit\n'
end)

-- Bell -> mark the tab (cleared when the tab becomes active).
wezterm.GLOBAL.bell_tabs = wezterm.GLOBAL.bell_tabs or {}
wezterm.on('bell', function(window, pane)
  local tab = pane:tab()
  if tab and tab:tab_id() ~= window:mux_window():active_tab():tab_id() then
    local m = wezterm.GLOBAL.bell_tabs
    m[tostring(tab:tab_id())] = true
    wezterm.GLOBAL.bell_tabs = m
  end
end)

wezterm.on('format-tab-title', function(tab)
  local id = tostring(tab.tab_id)
  local m = wezterm.GLOBAL.bell_tabs
  if tab.is_active and m[id] then
    m[id] = nil
    wezterm.GLOBAL.bell_tabs = m
  end
  local mark = m[id] and '🔔 ' or ''
  local title = tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title
  local text = ' ' .. tab.tab_index + 1 .. ': ' .. mark .. title .. ' '
  if m[id] then
    return { { Background = { Color = '#d65d0e' } }, { Foreground = { Color = '#1d2021' } }, { Text = text } }
  end
  return text
end)

config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, _) new_session_tab(window) end) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' }, -- plain shell tab
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'j', mods = 'ALT', action = act.ActivateTabRelative(1) },
  { key = 'k', mods = 'ALT', action = act.ActivateTabRelative(-1) },
}

return config
