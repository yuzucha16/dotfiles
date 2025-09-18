#Requires AutoHotkey v2.0

; Assign 変換
sc079::RWin 				; 変換 -> Right Window
RControl & Space:: Send "{sc029}"	; Ctrl + Space -> 半角全角
Sleep 2
Return

; Assign arrow key
sc07B & h:: Send "{Left}"   ;無変換 + h
sc07B & j:: Send "{down}"
sc07B & k:: Send "{up}"
sc07B & l:: Send "{right}"