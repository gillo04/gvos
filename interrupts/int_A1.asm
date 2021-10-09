;;; ------------------------0x00---------------------------
DecStrToNum8:
    cmp byte[esi], 0
    je DecStrToNum8_error
    mov cl, 0       ; String size
    mov bl, 0       ; Final result

    push esi
    DecStrToNum8_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum8_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum8_error
        cmp byte[esi], '9'
        jg DecStrToNum8_error
        inc esi
        inc cl
        cmp cl, 3
        jg DecStrToNum8_error
        jmp DecStrToNum8_reachEnd

    DecStrToNum8_addPreLoop:
        pop esi
    DecStrToNum8_addLoop:
        mov al, 1
        push cx
        DecStrToNum8_powerLoop:
            cmp cl, 1
            je DecStrToNum8_powerLoopEnd
            mov dl, 10
            mul dl
            dec cl
            jmp DecStrToNum8_powerLoop
        DecStrToNum8_powerLoopEnd:
        pop cx
        mov dl, [esi]
        sub dl, 48
        mul dl
        add bl, al
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum8_exit
        jmp DecStrToNum8_addLoop

    DecStrToNum8_error:
        mov al, 1
        iret

    DecStrToNum8_exit:
        mov al, 0
        iret

;;; ------------------------0x01---------------------------
DecStrToNum16:
    cmp byte[esi], 0
    je DecStrToNum16_error
    mov cl, 0       ; String size
    mov bx, 0       ; Final result

    push esi
    DecStrToNum16_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum16_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum16_error
        cmp byte[esi], '9'
        jg DecStrToNum16_error
        inc esi
        inc cl
        cmp cl, 5
        jg DecStrToNum16_error
        jmp DecStrToNum16_reachEnd

    DecStrToNum16_addPreLoop:
        pop esi
    DecStrToNum16_addLoop:
        mov ax, 1
        push cx
        DecStrToNum16_powerLoop:
            cmp cl, 1
            je DecStrToNum16_powerLoopEnd
            mov dx, 10
            mul dx
            dec cl
            jmp DecStrToNum16_powerLoop
        DecStrToNum16_powerLoopEnd:
        pop cx
        mov dh, 0
        mov dl, [esi]
        sub dl, 48
        mul dx
        add bx, ax
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum16_exit
        jmp DecStrToNum16_addLoop

    DecStrToNum16_error:
        mov al, 1
        iret

    DecStrToNum16_exit:
        mov al, 0
        iret

;;; ------------------------0x02---------------------------
DecStrToNum32:
    cmp byte[esi], 0
    je DecStrToNum32_error
    mov cl, 0       ; String size
    mov ebx, 0       ; Final result

    push esi
    DecStrToNum32_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum32_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum32_error
        cmp byte[esi], '9'
        jg DecStrToNum32_error
        inc esi
        inc cl
        cmp cl, 10
        jg DecStrToNum32_error
        jmp DecStrToNum32_reachEnd

    DecStrToNum32_addPreLoop:
        pop esi
    DecStrToNum32_addLoop:
        mov eax, 1
        push cx
        DecStrToNum32_powerLoop:
            cmp cl, 1
            je DecStrToNum32_powerLoopEnd
            mov edx, 10
            mul edx
            dec cl
            jmp DecStrToNum32_powerLoop
        DecStrToNum32_powerLoopEnd:
        pop cx
        mov edx, 0
        mov dl, [esi]
        sub dl, 48
        mul edx
        add ebx, eax
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum32_exit
        jmp DecStrToNum32_addLoop

    DecStrToNum32_error:
        mov al, 1
        iret

    DecStrToNum32_exit:
        mov al, 0
        iret

;;; ------------------------0x03---------------------------
NumToDecStr8:
    mov ah, 0
    mov al, bl
    mov edi, esi

    NumToDecStr8_loop:
        mov dl, 10
        div dl
        add ah, 48
        mov [esi], ah
        inc esi
        mov ah, 0
        cmp al, 0
        jne NumToDecStr8_loop

    NumToDecStr8_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr8_reverseString

    iret

;;; ------------------------0x04---------------------------
NumToDecStr16:
    mov dx, 0
    mov ax, bx
    mov edi, esi

    NumToDecStr16_loop:
        mov bx, 10
        div bx
        add dl, 48
        mov [esi], dl
        inc esi
        mov dx, 0
        cmp ax, 0
        jne NumToDecStr16_loop

    NumToDecStr16_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr16_reverseString

    iret

;;; ------------------------0x05---------------------------
NumToDecStr32:
    mov edx, 0
    mov eax, ebx
    mov edi, esi

    NumToDecStr32_loop:
        mov ebx, 10
        div ebx
        add dl, 48
        mov [esi], dl
        inc esi
        mov edx, 0
        cmp eax, 0
        jne NumToDecStr32_loop

    NumToDecStr32_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr32_reverseString
    
    iret

;;; ------------------------0x06---------------------------


;;; ------------------------0x07---------------------------
NumToHexStr8:
    mov cl, 0
    NumToHexStr8_loop:
        ror bl, 4
        push bx
        and bl, 0x0f
        cmp bl, 9
        jg NumToHexStr8_letter
        add bl, 48
        jmp NumToHexStr8_letter_end
        NumToHexStr8_letter:
        add bl, 65-10
        NumToHexStr8_letter_end:
        mov [esi], bl
        pop bx
        inc esi
        inc cl
        cmp cl, 2
        jne NumToHexStr8_loop

    iret