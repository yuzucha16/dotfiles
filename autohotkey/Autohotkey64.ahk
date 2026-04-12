#Requires AutoHotkey v2.0

; Assign 変換
sc079::RWin 				; 変換 -> Right Window
Sleep 2
Return

; Assign arrow key
sc07B & h:: Send "{Left}"   ;無変換 + h
sc07B & j:: Send "{down}"
sc07B & k:: Send "{up}"
sc07B & l:: Send "{right}"

sc07B & u:: Send "{PgUp}"   ;無変換 + u
sc07B & m:: Send "{PgDn}"
sc07B & i:: Send "{Home}"
sc07B & ,:: Send "{End}"

sc07B & f:: Send "{Enter}"
sc07B & a:: Send "{Backspace}"
sc07B & s:: Send "{Delete}"
sc07B & Space:: Send "{vkF3}" ;無変換 + space -> 半角全角

; obs
;RControl & Space:: Send "{sc029}"	; Ctrl + Space -> 半角全角
