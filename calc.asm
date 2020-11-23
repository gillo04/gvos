calc:
    call ClearScreen
    xor dx, dx
    call SetCursorPosition
    
    mov esi, stringa
    mov edi, 2
    call StringToNumber
    mov ah, 0x0e
    int 0x10

    call GetKeyPress
    jmp JumpToKernel
    
    stringa db "35", 0

%include 'string_utils.asm'
%include 'math_utils.asm'
%include 'disk_utils.asm'
    
times 512*2 -($-$$) db 0