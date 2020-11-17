bits 16
org 0x7c00

jmp _start
    loadingMsg db "Loanding the kernel...", 0x0a, 0x0d, 0
    successMsg db "Kernel loaded seuccessfully!", 0x0a, 0x0d, 0
    errorMsg db "Error in loading the kernel.", 0x0a, 0x0d, 0
_start:

    ;mov esi, loadingMsg
    ;call PrintString

    ; set es:bx memory address
    mov bx, 0x1000
    mov es, bx
    mov bx, 0

    ; setup disk read
    xor dx, dx  ; dh = head 0, dl = drive 0
    mov ch, 0   ; ch = cylinder 0
    mov cl, 2   ; cl = starting sector 2

_readDisk:
    mov ah, 0x02
    mov al, 0x02    ; how many sectors to write
    int 0x13

    jc _readDisk    ; if there's an error, int 13 will return a carry. retry

    ; reset segment registers
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x1000:0x0 ; jump to the kernel!
;includes
    ;%include 'standard_functions.asm'

times 510 -($-$$) db 0
dw 0xaa55