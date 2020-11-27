;; file_name-starting_sector-length
;; file names can be only 8 characters long!!!!!

db "|calc-07-02|tris-09-02|doc-11-01|numbers-12-01|edit-13-04"

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
; 11: doc
; 12: numbers
; 13: edit
; 14: edit
; 15: edit
; 16: edit

times 512 - ($-$$) db 0