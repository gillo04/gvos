GetKeyPress: ; key pressed returned to al
    push ebp
    mov ebp, esp

    mov ah, 0x00
    _GetKeyPressloop0:
        int 0x16
        cmp al, 0x00
        je _GetKeyPressloop0

    mov esp, ebp
    pop ebp
    ret

GetInputString: ; put the output string label in esi and the string lenght in edi. the string at esi will be modified
    push ebp
    mov ebp, esp

    mov edx, esi

    GetInputStringLoop0:
        call GetKeyPress
        cmp al, 0x0d
        je GetInputStringExit

        cmp al, 0x08
        je GetInputStringBackSpace
        
        sub esi, edx
        cmp esi, edi
        jge GetInputStringBufferFull
        add esi, edx
        
        ;_addChar:
            mov [esi], al
            mov ah, 0x0e
            int 0x10
            inc esi
            jmp GetInputStringLoop0

        GetInputStringBackSpace:
            cmp esi, edx
            je GetInputStringLoop0
            dec esi
            mov byte [esi], 0x00
            call BackSpace
            jmp GetInputStringLoop0
        
        GetInputStringBufferFull:
            add esi, edx
            jmp GetInputStringLoop0

    GetInputStringExit:

    mov esp, ebp
    pop ebp
    ret

PrintString: ; put string label in esi
    push ebp
    mov ebp, esp
    
    mov ah, 0x0e

    PrintStringLoop0:
        mov al, [esi]
        int 0x10
        inc esi
        cmp byte[esi], 0
        jne PrintStringLoop0

    mov esp, ebp
    pop ebp
    ret

CompareStrings: ; put strings in esi and edi, returns 1 in al if they are equal, else returns 0
    push ebp
    mov ebp, esp

    CompareStringsLoop0:
        mov ah, [esi]
        mov al, [edi]
        cmp ah, al
        jne CompareStringsFalse
        
        cmp ah, 0x00
        je CompareStringsTrue

        inc esi
        inc edi
        jmp CompareStringsLoop0

    CompareStringsTrue:
        mov al, 1
        jmp CompareStringsEnd

    CompareStringsFalse:
        mov al, 0

    CompareStringsEnd:
    mov esp, ebp
    pop ebp
    ret

BackSpace:
    push ebp
    mov ebp, esp

    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10

    mov esp, ebp
    pop ebp
    ret

NewLine:
    push ebp
    mov ebp, esp

    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10

    mov esp, ebp
    pop ebp
    ret