;; file_name-starting_sector-length

db "|calc-05-02|tris-07-02"

; Sectors configuration
; 1: boot loader
; 2: file list
; 3: kernel
; 4: kernel
; 5: calc
; 6: calc
; 7: tris
; 8: tris

times 512 - ($-$$) db 0