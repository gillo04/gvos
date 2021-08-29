%include "constants.asm"

mov esi, msg
mov ah, 0x00
int 0xa0

jmp $

msg db "This program is used to test functions."

times 512 - ($ - $$) db 0