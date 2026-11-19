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
  -- zellij なしの素のシェル（毎回新しいタブ）。pwsh は scoop の pwsh7（PATH 上の pwsh）。
  { label = 'pwsh (Windows)', where = 'plain', args = { 'pwsh' } },
  { label = 'cmd (Windows)', where = 'plain', args = { 'cmd.exe' } },
  { label = 'room-' .. AREA .. ' (shell)', where = 'plain', domain = ROOM, cwd = '~' },
}

local function basename(p)
  return (p:gsub('[/\\]+$', ''):match('([^/\\]+)$')) or p
end

-- 同じ「環境: cwd の名前」のタブがあれば、新しく作らずそこへ移る。
local function open_target(window, target)
  if target.where == 'plain' then
    window:mux_window():spawn_tab {
      domain = { DomainName = target.domain or 'local' },
      args = target.args,
      cwd = target.cwd,
    }
    return
  end
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
    -- zellij は Windows で既定のシェルが cmd になり、SHELL 環境変数は見ない（2026-11-19 実機）。
    -- pwsh7 は options --default-shell で渡す（新しいセッションだけに効く。既存は作り直す）。
    -- --default-cwd は claude2 の swap layout を崩す（2026-11-19 実機で切り分け）ので使わない。
    -- spawn_tab の cwd は zellij の pane に届かず ~ になった。pwsh で cd してから zellij を起動する。
    -- クライアントが作ったセッションは、最初の layout が swap layout に乗らず、Alt+c の 1 回目が
    -- nvim の右に出る。先に背景でセッションを作ってから attach する（2026-11-19 実機で確認）。
    local ps = table.concat({
      "Set-Location -LiteralPath '" .. target.cwd .. "'",
      "$n = '" .. name .. "'",
      "if (-not ((zellij list-sessions -n 2>$null) -split \"`n\" | Where-Object { ($_ -split ' ')[0] -eq $n })) {",
      "  zellij attach --create-background $n options --default-shell pwsh | Out-Null }",
      "zellij attach $n",
    }, '\n')
    spec.args = { 'pwsh.exe', '-NoLogo', '-Command', ps }
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

-- タブバーの「+」: 右クリックの既定（ランチャー）は残し、左・中クリックで候補を選ぶ。
wezterm.on('new-tab-button-click', function(window, pane, button)
  if button == 'Right' then return end
  window:perform_action(pick_target, pane)
  return false
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

local function mark_bell(window, pane)
  local tab = pane:tab()
  if tab and tab:tab_id() ~= window:mux_window():active_tab():tab_id() then
    local m = wezterm.GLOBAL.bell_tabs
    m[tostring(tab:tab_id())] = true
    wezterm.GLOBAL.bell_tabs = m
    refresh_status(window)
  end
end

wezterm.on('bell', mark_bell)

-- win は BEL（ConPTY が止める）も OSC 1337（zellij が止める）も届かない（2026-11-19 実機）。
-- win の claude のフック（~/.claude/hooks/bell-mark.ps1）が %TEMP%\wezterm-bell\<pane_id> を置くので、
-- update-status で拾って印を付け、ファイルを消す。
local bell_dir = (os.getenv('TEMP') or '') .. '\\wezterm-bell'
wezterm.on('update-status', function(window)
  for _, f in ipairs(wezterm.glob(bell_dir .. '/*')) do
    local pane = wezterm.mux.get_pane(tonumber(f:match('([^/\\]+)$')) or -1)
    if pane then mark_bell(window, pane) end
    os.remove(f)
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

-- コピー・ペーストは Windows Terminal に合わせる。
-- 選択中: コピーして選択を解除。未選択: Ctrl+C はそのまま渡す（^C）、右クリックはペースト。
-- 選択は WezTerm 自身の選択だけが対象（zellij の mouse_mode が true だと、選択は zellij 側になる）。
local function copy_or_else(fallback)
  return wezterm.action_callback(function(window, pane)
    local sel = window:get_selection_text_for_pane(pane)
    if sel ~= '' then
      window:perform_action(act.CopyTo 'Clipboard', pane)
      window:perform_action(act.ClearSelection, pane)
    else
      window:perform_action(fallback, pane)
    end
  end)
end
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE', action = copy_or_else(act.PasteFrom 'Clipboard') },
}

-- WezTerm のキーは Ctrl+Shift と、コピー・ペースト（Ctrl+C / Ctrl+V）だけ（Alt は zellij、Space は nvim）。
config.keys = {
  { key = 'c', mods = 'CTRL', action = copy_or_else(act.SendKey { key = 'c', mods = 'CTRL' }) },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 't', mods = 'CTRL|SHIFT', action = pick_target },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab { domain = { DomainName = 'local' }, args = { 'pwsh' } } }, -- 素の pwsh7（Windows）
}

return config
