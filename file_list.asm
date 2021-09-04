db "test      ", 0x00, 0x0a, 0x01
db "edit      ", 0x00, 0x0b, 0x02
db "doc       ", 0x00, 0x0d, 0x01
db "3d        ", 0x00, 0x0e, 0x03

;  1: boot loader
;  2: interrupts
;  3: interrupts
;  4: file list
;  5: kernel
;  6: kernel
;  7: kernel
;  8: kernel
;  9: kernel
; 10: test
; 11: edit
; 12: edit
; 13: doc


times 512 - ($-$$) db 0x00