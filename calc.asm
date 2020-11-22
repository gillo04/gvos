calc:
    mov esi, CalcVar0
    mov ah, 20
    mov al, 0
    call FillString

    jmp Cm_calc0
    CalcStr0 db "Expression: ", 0

    CalcVar0 times 20 db 0
    CalcVar1 db 0, 0, 0, 0


    Cm_calc0:
        mov esi, CalcStr0
        call PrintString

        mov esi, CalcVar0
        mov edi, 19
        call GetInputString

        mov esi, CalcVar0
        mov edi, CalcVar1
    Cm_calc1:
        mov ah, [esi]
        call CharIsNumber
        cmp al, 0
        je Cm_calc2
        mov dl, [esi]
        mov [edi], dl
        inc esi
        inc edi
        jmp Cm_calc1

    Cm_calc2:
        mov esi, CalcVar1
        call StringToNumber

        mov ah, 0x0e
        int 0x10
        ;mov esi, CalcVar1
        ;call PrintString

    jmp JumpToKernel
    
%include 'string_utils.asm'
%include 'math_utils.asm'
%include 'disk_utils.asm'
    
times 512*2 -($-$$) db 0