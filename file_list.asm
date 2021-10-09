;   name         cylinder | head | sector | size
db "test      ", 0,         0,      15,     1
db "edit      ", 0,         0,      16,     2
db "doc       ", 0,         0,      18,     1
db "3d        ", 0,         1,      1,      3
db "calc      ", 0,         1,      4,      2
db "font      ", 0,         1,      6,      4
db "game      ", 0,         1,      10,     2
; db "cad       ", 0,         1,      12,     4

;  1: boot loader
;  2: interrupts
;  3: interrupts
;  4: interrupts
;  5: interrupts
;  6: interrupts
;  7: interrupts
;  8: interrupts
;  9: file list
; 10: kernel
; 11: kernel
; 12: kernel
; 13: kernel
; 14: kernel
; 15: test
; 16: edit
; 17: edit
; 18: doc

;  1: 3d
;  2: 3d
;  3: 3d
;  4: calc
;  5: calc
;  6: font
;  7: font
;  8: font
;  9: font
; 10: game
; 11: game
; 12: cad
; 13: cad
; 14: cad


times 512 * 2 - ($-$$) db 0x00