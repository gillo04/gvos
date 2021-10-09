;;; ------------------------0x00---------------------------
PrintString:
    mov ah, 0x0e
    PrintString_loop:
        mov al, [esi]
        int 0x10
        inc esi
        cmp byte [esi], 0
        jne PrintString_loop
    iret

jmp $

;;; ------------------------0x01---------------------------
GetKeyPress:
    mov ah, 0x00
    _GetKeyPressloop0:
        int 0x16
        cmp al, 0x00
        je _GetKeyPressloop0

    iret

;;; ------------------------0x02---------------------------
GetInputString:
    mov edx, esi

    GetInputStringLoop0:
        mov ah, 0x01
        int 0xa0
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
            mov ah, 0x04
            int 0xa0        ; BackSpace
            jmp GetInputStringLoop0
        
        GetInputStringBufferFull:
            add esi, edx
            jmp GetInputStringLoop0

    GetInputStringExit:

    iret

;;; ------------------------0x03---------------------------
NewLine:
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    iret

;;; ------------------------0x04---------------------------
BackSpace:
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10
    iret

;;; ------------------------0x05---------------------------
ClearScreen:
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x1950
    int 0x10

    iret

;;; ------------------------0x06---------------------------
SetCursorPosition: ; DH: row, DL: column
    mov ah, 0x02
    mov bh, 0
    int 0x10

    iret