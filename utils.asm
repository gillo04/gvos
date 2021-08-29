%include "constants.asm"

NumberToHex: ; ESI: pointer to output string, AL: number
    push ax
    mov bl, 0

    NumberToHexLoop:
    cmp bl, 2
    je NumberToHexExit
    and al, 0x0f
    cmp al, 9
    jg NumberToHexLetter
        add al, 48
        jmp NumberToHexLetterEnd
    NumberToHexLetter:
        add al, 55
    NumberToHexLetterEnd:
        mov [esi+1], al
    
    pop ax
    push ax
    rol al, 4
    inc bl
    dec esi
    jmp NumberToHexLoop

    NumberToHexExit:
    pop ax
    ret

NumberToString8: ; EIS: string label, AL: number
    push ebp
    mov ebp, esp

    mov cx, 10
    mov edi, esi

    mov ah, 0

    NumberToString8Loop:
        push ax
        xor dx, dx
        div cx
        add dx, 48
        mov [esi], dl
        sub dx, 48
        cmp ax, 0
        je NumberToString8Loop1
        inc esi
        pop ax
        sub ax, dx
        xor dx, dx
        div cx
        jmp NumberToString8Loop

    NumberToString8Loop1: ; inverting the string
        cmp edi, esi
        jge NumberToStringExit
        mov bl, [edi]
        mov bh, [esi]
        mov [esi], bl
        mov [edi], bh
        inc edi
        dec esi
        jmp NumberToString8Loop1

    NumberToStringExit:

    mov esp, ebp
    pop ebp
    ret

JumpToKernel:
    mov bx, KERNEL_SEGMENT
    mov ds, bx
    jmp KERNEL_SEGMENT:KERNEL_ADDR