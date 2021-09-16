%include "constants.asm"

; Load the font at 0x800
mov esi, fontStr
mov ah, 0x02
int 0xa2

mov bx, PROGRAM_SEGMENT
mov es, bx
mov bx, 0x800

mov dl, 0
mov dh, ch
mov ch, 0

mov ah, 0x00
int 0xa2        ; LoadSectors


mov ah, 0x00
int 0xb0

mov ebx, (5 << 16) | 5
mov esi, testStr
mov edi, 0x800
mov al, 0x28
mov cx, 2
mov dx, 11
mov ah, 0x08
int 0xb0

mov ebx, (30 << 16) | 5
mov esi, testStr
mov edi, 0x800
mov al, 0x0f
mov cx, 3
mov dx, 16
mov ah, 0x08
int 0xb0



mov ebx, (100 << 16) | 20
mov cx, 15
mov dx, 1
mov al, 0x30
mov ah, 0x05
int 0xb0

mov ebx, (100 << 16) | 60
mov cx, 15
mov dx, 5
mov al, 0x2a
mov ah, 0x05
int 0xb0

mov ebx, (100 << 16) | 100
mov cx, 15
mov dx, 10
mov al, 0x37
mov ah, 0x05
int 0xb0

mov ebx, (100 << 16) | 200
mov cx, 15
mov al, 0x5c
mov ah, 0x04
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




; mov esi, msg
; mov ah, 0x00
; int 0xa0

; exitLoop:
;     mov ah, 0x01
;     int 0xa0
;     cmp al, 'x'
;     jne exitLoop

; jmp JumpToKernel

; msg db 0x0d, 0x0a, "This program is used to test functions.",0x0d, 0x0a, "Press X to exit",0
testStr db "HELLO WORLD", 0
fontStr db "font", 0

%include "utils.asm"

times 512 - ($ - $$) db 0