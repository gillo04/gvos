FindFile: ; put filename label in ESI, returns 1 in AL if found, starting sector in BH and length in BL
    push ebp
    mov ebp, esp

    push esi
    mov bx, 0x1000 ; location of the file list in memory
    mov es, bx
    mov bx, 0
        
    findFileInFilesystem: ; finds where in the filesystem the file is located
        pop esi
        push esi
        findStartOfNextFileDef:
            cmp byte[es:bx], '|'
            je compareNextChar
            cmp byte[es:bx], 0
            je fileNotFound
            inc bx
            jmp findStartOfNextFileDef

        compareNextChar:
            inc bx
            mov al, [esi]
            cmp al, [es:bx]
            jne findFileInFilesystem
            cmp al, '-'
            je fileFound
            inc esi
            jmp compareNextChar

    startingSectorStr db 0, 0, 0
    lengthStr db 0, 0, 0

    fileNotFound:
        mov al, 0
        jmp FindFileExit
    
    fileFound:
        mov esi, startingSectorStr
        inc bx
        mov cl, [es:bx]
        mov [esi], cl
        inc bx
        inc esi
        mov cl, [es:bx]
        mov [esi], cl

        mov esi, lengthStr
        add bx, 2
        mov cl, [es:bx]
        mov [esi], cl
        inc bx
        inc esi
        mov cl, [es:bx]
        mov [esi], cl

        mov esi, startingSectorStr
        mov edi, 2
        call StringToNumber
        mov bh, al
        push bx

        mov esi, lengthStr
        mov edi, 2
        call StringToNumber
        pop bx
        mov bl, al

        mov al, 1

    FindFileExit:

    mov esp, ebp
    pop ebp
    ret