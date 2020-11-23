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

NumberToString: ; put string label in ESI, put number in AX
    push ebp
    mov ebp, esp

    mov cx, 10

    NumberToStringLoop:
        push ax
        xor dx, dx
        div cx
        add dx, 48
        mov [esi], dl
        sub dx, 48
        inc esi
        cmp ax, 0
        je NumberToStringExit
        pop ax
        sub ax, dx
        xor dx, dx
        div cx
        jmp NumberToStringLoop

    NumberToStringExit:

    mov esp, ebp
    pop ebp
    ret