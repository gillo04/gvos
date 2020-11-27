CharIsNumber: ; put char in AH, returns 1 in AL if AH is a number. will override BL
    push ebp
    mov ebp, esp

    mov al, 0
    mov bl, "0"-1
    CharIsNumberLoop0:
        inc bl
        cmp bl, ":"
        je CharIsNumberExit
        cmp ah, bl
        jne CharIsNumberLoop0

    mov al, 1
    CharIsNumberExit:

    mov esp, ebp
    pop ebp
    ret

StringToNumber: ; put string label in ESI, put string length in EDI returns number in AX
    push ebp
    mov ebp, esp

    push esi
    xor edi, edi
    StringToNumberLooppone:
        cmp byte[esi], 0
        je StringToNumberLoopponeEnd
        inc edi
        inc esi
        jmp StringToNumberLooppone
    StringToNumberLoopponeEnd:

    pop esi
    xor cx, cx
    mov bx, 10
    mov ax, 1
    StringToNumberLoop:
        dec edi
        cmp edi, 0
        je StringToNumberEndLoop
        mul bx
        jmp StringToNumberLoop
    StringToNumberEndLoop:
        ;mov bx, ax

    StringToNumberLoop0:
        push ax
        xor dx, dx
        mov dl, [esi]
        sub dx, 0x30
        mul dx

        add cx, ax

        pop ax
        cmp ax, 1
        je StringToNumberExit
        inc esi
        div bx

        jmp StringToNumberLoop0

    StringToNumberExit:
        mov ax, cx

    mov esp, ebp
    pop ebp
    ret

NumberToString: ; put string label in ESI, put number in AX, changes every register
    push ebp
    mov ebp, esp

    mov cx, 10
    mov edi, esi

    NumberToStringLoop:
        push ax
        xor dx, dx
        div cx
        add dx, 48
        mov [esi], dl
        sub dx, 48
        cmp ax, 0
        je NumberToStringLoop1
        inc esi
        pop ax
        sub ax, dx
        xor dx, dx
        div cx
        jmp NumberToStringLoop

    NumberToStringLoop1: ; inverting the string
        cmp edi, esi
        jge NumberToStringExit
        mov bl, [edi]
        mov bh, [esi]
        mov [esi], bl
        mov [edi], bh
        inc edi
        dec esi
        jmp NumberToStringLoop1

    NumberToStringExit:

    mov esp, ebp
    pop ebp
    ret

HexNumberToString: ; put number in AL, returns string in the form of two bytes in DX
    push ebp
    mov ebp, esp

    push ax
    mov bl, 00001111b
    and al, bl
    add al, 48
    mov bh, al
    pop ax
    mov ah, bh
    mov bl, 11110000b
    and al, bl
    ; mov cl, 4
    ror al, 4
    add al, 48
    mov dh, al
    mov dl, ah
    cmp dl, '9'
    jg letterFixDL
    jmp exitLetterFixDL

    letterFixDL:
    sub dl, 48
    add dl, 55

    exitLetterFixDL:
    cmp dh, '9'
    jg letterFixDH
    jmp HexNumberToStringExit

    letterFixDH:
    sub dh, 48
    add dh, 55

    HexNumberToStringExit:

    mov esp, ebp
    pop ebp
    ret
