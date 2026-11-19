-- WezTerm: 環境 + cwd でタブを開き、zellij を起動する。bell でタブに印を付ける。
-- 設計: docs/setup/terminal-units.md（5〜7 章）。pane の配置は zellij（home/.config/zellij）の担当。
-- Linked to %USERPROFILE%\.config\wezterm\wezterm.lua by manifests\links.map.
-- 作らないもの: WezTerm の pane 分割・workspace、Alt キー（Alt は zellij 用）。
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- room: 共有の WSL 部屋（ユーザー ai、/mnt/c なし）。ディストリビューションは room-<Area>。
local AREA = os.getenv('WEZTERM_ROOM_AREA') or 'myenv'
local ROOM = 'WSL:room-' .. AREA
config.wsl_domains = {
  { name = ROOM, distribution = 'room-' .. AREA, username = 'ai', default_cwd = '~' },
}
-- Windows の環境変数（WSLENV の /p パス）を部屋へ渡さない（room.py の wsl_env を参照）。
config.set_environment_variables = { WSLENV = '' }

-- 見た目
config.font = wezterm.font_with_fallback { 'PlemolJP Console NF', 'Cascadia Mono', 'Consolas' }
config.font_size = 11.0
config.color_scheme = 'Gruvbox Dark (Gogh)'
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.audible_bell = 'Disabled' -- 音は鳴らさない。印だけ
config.window_close_confirmation = 'NeverPrompt'

-- 環境（where）と cwd の候補。win = Windows の zellij、room = 部屋の zellij。
local WORKS = os.getenv('WORKS_DIR') or (wezterm.home_dir .. '\\works')
local TARGETS = {
  { label = 'room: ~ (home)', where = 'room', cwd = '~' },
  { label = 'win:  resources', where = 'win', cwd = WORKS .. '\\resources' },
  { label = 'win:  works', where = 'win', cwd = WORKS },
  { label = 'win:  dotfiles', where = 'win', cwd = WORKS .. '\\repos\\github.com\\yuzucha16\\dotfiles' },
}

local function basename(p)
  return (p:gsub('[/\\]+$', ''):match('([^/\\]+)$')) or p
end

-- 同じ「環境: cwd の名前」のタブがあれば、新しく作らずそこへ移る。
local function open_target(window, target)
  local name = basename(target.cwd == '~' and 'home' or target.cwd)
  local title = target.where .. ': ' .. name
  for _, tab in ipairs(window:mux_window():tabs()) do
    if tab:get_title() == title then
      tab:activate()
      return
    end
  end
  local spec = { cwd = target.cwd }
  if target.where == 'win' then
    spec.domain = { DomainName = 'local' }
    spec.args = { 'zellij.exe', 'attach', '--create', name }
  else
    spec.domain = { DomainName = ROOM }
    -- login shell 経由（PATH に ~/.local/bin などを入れる）
    spec.args = { 'bash', '-lc', 'exec zellij attach --create ' .. name }
  end
  local tab = window:mux_window():spawn_tab(spec)
  tab:set_title(title)
end

-- Ctrl+Shift+T: 候補から選んでタブを開く。
local pick_target = wezterm.action_callback(function(window, pane)
  local choices = {}
  for i, t in ipairs(TARGETS) do
    choices[i] = { id = tostring(i), label = t.label }
  end
  window:perform_action(act.InputSelector {
    title = 'New session',
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(w, _, id)
      if id then open_target(w, TARGETS[tonumber(id)]) end
    end),
  }, pane)
end)

-- bell: 別のタブなら印を付け、そのタブへ移ったら消す。
wezterm.GLOBAL.bell_tabs = wezterm.GLOBAL.bell_tabs or {}
-- bell のイベントだけではタブバーが再描画されない（マウスを動かすまで印が出ない）。
-- 右ステータス（印のあるタブ数）を更新すると再描画されるので、bell のときと一定間隔で更新する。
config.status_update_interval = 500
local function refresh_status(window)
  local m = wezterm.GLOBAL.bell_tabs
  local active = tostring(window:mux_window():active_tab():tab_id())
  if m[active] then
    m[active] = nil
    wezterm.GLOBAL.bell_tabs = m
  end
  local n = 0
  for _ in pairs(m) do n = n + 1 end
  window:set_right_status(n > 0 and (' 🔔 ' .. n .. ' ') or '')
end
wezterm.on('update-status', refresh_status)

wezterm.on('bell', function(window, pane)
  local tab = pane:tab()
  if tab and tab:tab_id() ~= window:mux_window():active_tab():tab_id() then
    local m = wezterm.GLOBAL.bell_tabs
    m[tostring(tab:tab_id())] = true
    wezterm.GLOBAL.bell_tabs = m
    refresh_status(window)
  end
end)

wezterm.on('format-tab-title', function(tab)
  local id = tostring(tab.tab_id)
  local m = wezterm.GLOBAL.bell_tabs
  if tab.is_active and m[id] then
    m[id] = nil
    wezterm.GLOBAL.bell_tabs = m
  end
  local title = tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title
  if m[id] then
    return {
      { Background = { Color = '#d65d0e' } },
      { Foreground = { Color = '#1d2021' } },
      { Text = ' ' .. (tab.tab_index + 1) .. ': 🔔 ' .. title .. ' ' },
    }
  end
  return ' ' .. (tab.tab_index + 1) .. ': ' .. title .. ' '
end)

-- WezTerm のキーは Ctrl+Shift だけ（Alt は zellij、Space/Ctrl は nvim）。
config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = pick_target },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' }, -- 素のシェル
}

return config
