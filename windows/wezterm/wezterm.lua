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

-- 起動直後のタブ・Ctrl+Shift+N 以外の新規タブは、Windows の pwsh7（既定の cmd は使わない）。
config.default_prog = { 'pwsh' }

-- 見た目
config.font = wezterm.font_with_fallback { 'PlemolJP Console NF', 'Cascadia Mono', 'Consolas' }
config.font_size = 11.0
-- Windows Terminal の GruvboxDark（windows/terminal/settings.json の schemes）と同じ色。
config.color_schemes = {
  ['GruvboxDark'] = {
    foreground = '#EBDBB2',
    background = '#45413E',
    cursor_bg = '#EBDBB2',
    cursor_border = '#EBDBB2',
    cursor_fg = '#45413E',
    selection_bg = '#665C54',
    selection_fg = '#EBDBB2',
    ansi = { '#282828', '#CC241D', '#98971A', '#D79921', '#458588', '#B16286', '#689D6A', '#A89984' },
    brights = { '#928374', '#FB4934', '#B8BB26', '#FABD2F', '#83A598', '#D3869B', '#8EC07C', '#EBDBB2' },
  },
}
config.color_scheme = 'GruvboxDark'
-- タブバーの大きさ（文字・高さ）をWindows Terminal のタブバーに近い大きさにする（12pt）。retro タブバーは本文のフォントサイズに従い単独では変えられないため、
-- fancy タブバー + window_frame.font_size を使う（色は下の window_frame で gruvbox に寄せる）。
config.use_fancy_tab_bar = true
config.tab_max_width = 64
config.window_frame = {
  font = wezterm.font_with_fallback { 'PlemolJP Console NF', 'Cascadia Mono', 'Consolas' },
  font_size = 12.0,
  active_titlebar_bg = '#3A3735',
  inactive_titlebar_bg = '#3A3735',
}
-- OS 標準のタイトルバー（灰色の "pwsh.exe" の帯）をなくし、タブバーに最小化・最大化・閉じるを統合する（Windows Terminal と同じ）。
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.integrated_title_button_style = 'Windows'
-- タブの色: 選択中のタブは本文の背景 (#45413E) と同じにして、バーより一段明るく見せる。
config.colors = config.colors or {}
config.colors.tab_bar = {
  background = '#3A3735',
  active_tab = { bg_color = '#45413E', fg_color = '#EBDBB2' },
  inactive_tab = { bg_color = '#3A3735', fg_color = '#A89984' },
  inactive_tab_hover = { bg_color = '#4F4A46', fg_color = '#EBDBB2' },
  new_tab = { bg_color = '#3A3735', fg_color = '#A89984' },
  new_tab_hover = { bg_color = '#4F4A46', fg_color = '#EBDBB2' },
}
config.enable_scroll_bar = true -- 右端のスクロールバー（ドラッグ・クリックで scrollback を動かせる）
-- バーは右の padding の領域に出る。Windows Terminal に近づけ、幅は 2 セル（約 19px）の 2/3 ほどの 12px、
-- つまみは無彩色のグレーにする（gruvbox の gray は茶色寄りで、Windows Terminal と違って見えた）。
config.window_padding = { left = 0, right = '12px', top = 0, bottom = 0 }
config.colors.scrollbar_thumb = '#8f8f8f'
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

-- タブバーの「+」: 左クリックは無条件で Windows の pwsh7（Windows Terminal の既定シェルのボタンと同じ）。
-- 右・中クリックは候補の選択（Ctrl+Shift+T と同じ）。
local spawn_pwsh = act.SpawnCommandInNewTab { domain = { DomainName = 'local' }, args = { 'pwsh' } }
wezterm.on('new-tab-button-click', function(window, pane, button)
  window:perform_action(button == 'Left' and spawn_pwsh or pick_target, pane)
  return false
end)

-- Ctrl+Shift+D: 今のタブの zellij セッションを消し（delete-session --force）、タブを閉じる。
-- タブ名（"win: <名>" / "room: <名>"）がセッション名。zellij なしのタブ（pwsh など）は、ただ閉じる。
local delete_session = wezterm.action_callback(function(window, pane)
  local title = window:active_tab():get_title()
  local where, name = title:match('^(%a+): (.+)$')
  if where == 'win' then
    wezterm.run_child_process { 'zellij', 'delete-session', '--force', name }
  elseif where == 'room' then
    wezterm.run_child_process { 'wsl', '-d', 'room-' .. AREA, '-u', 'ai', '--', 'bash', '-lc',
      "zellij delete-session --force '" .. name .. "'" }
  end
  window:perform_action(act.CloseCurrentTab { confirm = false }, pane)
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
  { key = 'n', mods = 'CTRL|SHIFT', action = spawn_pwsh }, -- 素の pwsh7（Windows）
  { key = 'd', mods = 'CTRL|SHIFT', action = delete_session },
}

return config
