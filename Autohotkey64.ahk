#Requires AutoHotkey v2.0

; Swap Ctrl & Capslock
CapsLock::Ctrl
sc03A::Ctrl

; Assign 変換
sc079::RWin 					; 変換 -> Right Window
Ctrl & Space:: Send "{sc029}"	; Ctrl + Space -> 半角全角

; Assign arrow key
sc07B & h:: Send "{left}"   ;無変換 + h
sc07B & j:: Send "{down}"
sc07B & k:: Send "{up}"
sc07B & l:: Send "{right}"
