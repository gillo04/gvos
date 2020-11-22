tris:
    call ClearScreen
    xor dx, dx
    call SetCursorPosition
    jmp Cm_trisLoop0
    
    trisTable db "012345678", 0
    tmpRow db "0|0|0", 0x0a, 0x0d, 0
    trisLine db "-----", 0x0a, 0x0d, 0

    Cm_trisLoop0:
        call GetKeyPress
        sub al, 0x30
        cmp al, 9
        jge Cm_trisLoop0
        mov bl, al
        xor eax, eax
        mov al, bl

        mov byte [trisTable + eax], "X"
        
    Cm_tris0: ; print tris table

        mov al, [trisTable]
        mov bl, [trisTable+1]
        mov cl, [trisTable+2]

        mov [tmpRow], al
        mov [tmpRow+2], bl
        mov [tmpRow+4], cl

        mov esi, tmpRow
        call PrintString
        mov esi, trisLine
        call PrintString

        mov al, [trisTable+3]
        mov bl, [trisTable+4]
        mov cl, [trisTable+5]

        mov [tmpRow], al
        mov [tmpRow+2], bl
        mov [tmpRow+4], cl

        mov esi, tmpRow
        call PrintString
        mov esi, trisLine
        call PrintString

        mov al, [trisTable+6]
        mov bl, [trisTable+7]
        mov cl, [trisTable+8]

        mov [tmpRow], al
        mov [tmpRow+2], bl
        mov [tmpRow+4], cl
        
        mov esi, tmpRow
        call PrintString
        ;jmp Cm_trisLoop0
    
    call GetKeyPress
    jmp JumpToKernel

%include 'string_utils.asm'
%include 'disk_utils.asm'

times 512*2 -($-$$) db 0