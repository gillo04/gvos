;; file_name-starting_sector-length
;; file names can be only 8 characters long!!!!!

db "|calc-07-02|tris-09-02"

; Sectors configuration
; 1: boot loader
; 2: file list
; 3: kernel
; 4: kernel
; 5: kernel
; 6: kernel
; 7: calc
; 8: calc
; 9: tris
; 10: tris

times 512 - ($-$$) db 0