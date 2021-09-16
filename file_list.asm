;   name         head|sector|size
db "test      ", 0x00, 0x0c, 0x01
db "edit      ", 0x00, 0x0d, 0x02
db "doc       ", 0x00, 0x0f, 0x01
db "3d        ", 0x00, 0x10, 0x03
db "calc      ", 0x01, 0x01, 0x02
db "font      ", 0x01, 0x03, 0x02

;  1: boot loader
;  2: interrupts
;  3: interrupts
;  4: interrupts
;  5: interrupts
;  6: file list
;  7: kernel
;  8: kernel
;  9: kernel
;  a: kernel
;  b: kernel
;  c: test
;  d: edit
;  e: edit
;  f: doc
; 10: 3d
; 11: 3d
; 12: 3d
; 13: calc
; 14: calc


times 512 - ($-$$) db 0x00