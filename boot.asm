bits 16
org 0x7c00

_start:

    ; Load the file list
    ; set es:bx memory address
    mov ax, 0x1000
    mov es, ax
    mov bx, 0
    ; setup disk read
    mov ch, 0   ; ch = cylinder 0
    mov cl, 2   ; cl = starting sector 2
    mov al, 0x01    ; how many sectors to write

    call LoadSectors ; load program into memory

    ; Load the kernel
    ; set es:bx memory address
    mov ax, 0x2000
    mov es, ax
    mov bx, 0
    ; setup disk read
    mov ch, 0   ; ch = cylinder 0
    mov cl, 3   ; cl = starting sector 2
    mov al, 0x02    ; how many sectors to write

    call LoadSectors ; load program into memory
    jmp JumpToKernel
        

;     ; set es:bx memory address
;     mov bx, 0x2000
;     mov es, bx
;     mov bx, 0

;     ; setup disk read
;     xor dx, dx  ; dh = head 0, dl = drive 0
;     mov ch, 0   ; ch = cylinder 0
;     mov cl, 2   ; cl = starting sector 2

; _readDisk:
;     mov ah, 0x02
;     mov al, 0x02    ; how many sectors to write
;     int 0x13

;     jc _readDisk    ; if there's an error, int 13 will return a carry. retry

;     ; reset segment registers
;     mov ax, 0x2000
;     mov ds, ax
;     mov es, ax
;     mov fs, ax
;     mov gs, ax
;     mov ss, ax

;     jmp 0x2000:0x0 ; jump to the kernel!

%include "disk_utils.asm"

times 510 -($-$$) db 0
dw 0xaa55