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

StringToNumber: ; put string label in ESI, returns number in AL
    push ebp
    mov ebp, esp

    xor ch, ch
    mov bh, 100
    mov bl, 10

    StringToNumberLoop0:
        xor eax, eax
        mov al, [esi]
        sub eax, 0x30
        ;mov cl, bh
        mul bh

        add ch, al

        cmp bh, 1
        je StringToNumberExit

        inc esi
        xor ax, ax
        mov al, bh
        div bl

        mov bh, al
        jmp StringToNumberLoop0

    StringToNumberExit:
        mov al, ch

    mov esp, ebp
    pop ebp
    ret