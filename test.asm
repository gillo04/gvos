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

mov ebx, 0
mov ecx, (20 << 16) | 20
mov al, 0x0f
mov ah, 0x02
int 0xb0

exitLoop:
    mov ah, 0x01
    int 0xa0
    cmp al, 'x'
    jne exitLoop

mov ah, 0x01
int 0xb0
jmp JumpToKernel

jmp $

exampleGraphDef:
db 8
    dw 20, 20
    db 1
db 6
    dw 5, 5, 3, 15
    db "HELLO WORLD", 0
    dw 0x800
    db 0x28
    db 0
db 7
    dw 5, 40, 3
    dw svg
    db 0x28
    db 0
db 0
    dw 0, 0, 10, 10
    db 0
    db 0xff

svg:
db 3
db 2, 0
db 0, 3
db 4, 3
db 3
db 0, 1
db 1, 2
db 2, 0

%include "utils.asm"

times 512 - ($ - $$) db 0