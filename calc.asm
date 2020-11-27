calc:
    call ClearScreen
    xor dx, dx
    call SetCursorPosition
    
    mov esi, prompt1
    call PrintString
    mov esi, n1
    mov edi, 5
    call GetInputString
    
    ; mov esi, prompt2
    ; call PrintString
    ; call GetKeyPress
    ; mov [op], al
    
    mov esi, prompt3
    call PrintString
    mov esi, n2
    mov edi, 5
    call GetInputString

    mov esi, n1
    call StringToNumber
    mov [vals], ax
    mov esi, n2
    call StringToNumber
    mov bx, [vals]

    add ax, bx

    mov esi, result
    call NumberToString

    call NewLine
    call NewLine
    mov esi, n1
    call PrintString
    mov al, '+'
    mov ah, 0x0e
    int 0x10
    mov esi, n2
    call PrintString
    mov al, '='
    mov ah, 0x0e
    int 0x10
    mov esi, result
    call PrintString

    

    call GetKeyPress
    jmp JumpToKernel
    
    prompt1 db "n1: ", 0
    prompt2 db 0x0a, 0x0d, "op: ", 0
    prompt3 db 0x0a, 0x0d, "n2: ", 0
    n1 times 6 db 0
    op db 0
    n2 times 6 db 0
    vals dw 0
    result times 6 db 0

%include 'string_utils.asm'
%include 'math_utils.asm'
%include 'disk_utils.asm'
    
times 512*2 -($-$$) db 0