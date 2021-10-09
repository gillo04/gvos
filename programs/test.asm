%include "constants.asm"

; Load the font at 0x800
mov esi, fontStr
mov ah, 0x02
int 0xa2

mov bx, PROGRAM_SEGMENT
mov es, bx
mov bx, 0x800

mov dl, 0

mov ah, 0x00
int 0xa2        ; LoadSectors

mov ah, 0x00
int 0xb0

mov esi, exampleGraphDef
mov ah, 0x0a
int 0xb0

exitLoop:
    mov ah, 0x01
    int 0xa0
    cmp al, 'x'
    jne exitLoop

_exit:
mov ah, 0x01
int 0xb0
jmp JumpToKernel

jmp $

exampleGraphDef:
dw ge6
db 6
    dw 5, 5, 2, 10
    db "abcdefghijklmnop", 0
    dw 0x800
    db 0x0f
    db 0xff
    ge6:

%include "utils.asm"

times 512 - ($ - $$) db 0