%include "constants.asm"

mov esi, msg
mov ah, 0x00
int 0xa0

exitLoop:
    mov ah, 0x01
    int 0xa0
    cmp al, 'x'
    jne exitLoop

jmp JumpToKernel

msg db 0x0d, 0x0a, "This program is used to test functions.",0x0d, 0x0a, "Press X to exit",0
testStr db " 57", 0

%include "utils.asm"

times 512 - ($ - $$) db 0