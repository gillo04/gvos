;;; -------------------------------------------------------
;;;                       MEMORY MAP
;;; -------------------------------------------------------

;       0x7c00 - 0x7dff [1 sect]: Bootloader
;       0x7e00 - 0x7fff [1 sect]: File list
;       0x8000 - 0x8dff [7 sect]: System software interrupts
;       0x8e00 - 0x97ff [5 sect]: Operating system
;       =======================
;       0x10000 - 0x1ffff: Program memory

bits 16
org 0x7c00

%include "constants.asm"

_start:
    mov ax, 0
    mov dx, ax

    ; Load interrupts
    mov ax, 0
    mov es, ax
    mov bx, 0x8000
    mov ch, 0       ; Cylinder
    mov cl, 3       ; Starting sector
    mov al, 7       ; Sectors to write
    call LoadSectorsBoot

    ; Edit the IVT
    mov word [0xa0*4], intA0
    mov word [0xa0*4+2], cs
    
    mov word [0xa1*4], intA1
    mov word [0xa1*4+2], cs
    
    mov word [0xa2*4], intA2
    mov word [0xa2*4+2], cs

    mov word [0xb0*4], intB0
    mov word [0xb0*4+2], cs

    ; Load file list
    mov ax, FILE_LIST_SEGMENT
    mov es, ax
    mov bx, FILE_LIST_ADDR
    mov ch, 0       ; Cylinder
    mov cl, 2       ; Starting sector
    mov al, 1       ; Sectors to write
    call LoadSectorsBoot

    ; Load kernel
    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov bx, KERNEL_ADDR
    mov ch, 0       ; Cylinder
    mov cl, 10      ; Starting sector
    mov al, 5       ; Sectors to write
    call LoadSectorsBoot

    jmp KERNEL_SEGMENT:KERNEL_ADDR  ; Jump to kernel
    jmp $

LoadSectorsBoot: ; ES:BX: destination, CH: cylinder, CL: starting sector, AL: size
    xor dx, dx  ; dh = head 0, dl = drive 0
    LoadSectorsBoot_readDisk:
        mov ah, 0x02
        int 0x13

        jc LoadSectorsBoot_readDisk

    ret

times 510 - ($-$$) db 0x00
dw 0xaa55
%include "file_list.asm"
%include "interrupts/interrupts.asm"