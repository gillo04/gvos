org 0x8400

jmp _start
%include "utils.asm"
msg db "Hello", 0

welcomeMsg  db "Welcome to GVOS 3", 0x0d, 0x0a
            db "   - R file_name: Executes the program called 'file_name'", 0x0d, 0x0a
            db "   - I file_name: Prints info about the file called 'file_name'", 0x0d, 0x0a
            db "   - T: Prints the file system as a table", 0x0d, 0x0a, 0x00

shellCommand times 20 db 0

errorStr db 0x0d, 0x0a, "An error has occourred", 0x0d, 0x0a, 0x00
successStr db 0x0d, 0x0a, "Operation complated successfully", 0x0d, 0x0a, 0x00
debugStr db "Debug", 0

_start:
    mov ah, 0x05
    int 0xa0        ; ClearScreen
    xor dx, dx
    mov ah, 0x06
    int 0xa0        ; SetCursorPosition

    mov esi, welcomeMsg
    mov ah, 0x00
    int 0xa0

    _shellLoop:
    mov esi, shellCommand
    clearShellString:
        mov byte[esi], 0
        inc esi
        cmp byte[esi], 0
        jne clearShellString

    mov ah, 0x03
    int 0xa0        ; NewLine
    mov ah, 0x0e
    mov al, '>'
    int 0x10
    mov al, ' '
    int 0x10

    mov esi, shellCommand
    mov edi, 20
    mov ah, 0x02        ; GetInputString
    int 0xa0
    
    ; execute command
    _cmd0:
        cmp byte[shellCommand], 'R'
        jne _cmd1

        mov esi, shellCommand
        add esi, 2
        mov ah, 0x02
        int 0xa2        ; GetInfoFromFileName
        cmp al, 0
        je fileNotFound
        
        mov bx, PROGRAM_SEGMENT
        mov es, bx
        mov bx, 0

        mov ah, 0x00
        int 0xa2        ; LoadSectors

        mov bx, PROGRAM_SEGMENT
        mov ds, bx
        jmp PROGRAM_SEGMENT:0x0

        fileNotFound:
        mov esi, errorStr
        mov ah, 0x00
        int 0xa0

        jmp _shellLoop
        ;fileName times 10 db '#'
        ;db 0x00

    _cmd1:
        cmp byte[shellCommand], 'T'
        jne _cmd2

        
        mov bx, FILE_LIST_SEGMENT
        mov es, bx
        mov bx, FILE_LIST_ADDR

        _fileTableLoop:
            mov ah, 0x03
            int 0xa0        ; NewLine
            mov cl, 0
            _printName:
                mov ah, 0x0e
                mov al, [es:bx]
                int 0x10
                inc bx
                inc cl
                cmp cl, 10
                jne _printName

            mov cl, 0
            _printInfoNum:
                push cx
                mov ah, 0x0e
                mov al, ' '
                int 0x10

                mov byte[tempNumStr], ' '
                mov byte[tempNumStr + 1], ' '
                mov byte[tempNumStr + 2], ' '
                mov esi, tempNumStr
                mov al, [es:bx]
                push bx
                mov bl, al
                mov ah, 0x03
                int 0xa1        ; NumberToString8
                mov esi, tempNumStr
                mov ah, 0x00
                int 0xa0
                pop bx
                inc bx
                pop cx
                inc cl
                cmp cl, 0x03
                jl _printInfoNum

            cmp byte[es:bx], 0x00
            jne _fileTableLoop
        
        jmp _shellLoop
        tempNumStr db "   ", 0x00

    _cmd2:
        cmp byte[shellCommand], 'I'
        jne _cmd3

        mov ah, 0x03
        int 0xa0        ; NewLine

        mov esi, shellCommand
        add esi, 2
        mov ah, 0x02
        int 0xa2        ; GetInfoFromFileName
        cmp al, 0
        je fileNotFound2
        
        mov cl, 0
        printInfoNum:
            push cx
            mov ah, 0x0e
            mov al, ' '
            int 0x10

            mov byte[tempNumStr2], ' '
            mov byte[tempNumStr2 + 1], ' '
            mov byte[tempNumStr2 + 2], ' '
            mov esi, tempNumStr2
            mov al, [es:bx]
            push bx
            mov bl, al
            mov ah, 0x03
            int 0xa1        ; NumberToString8
            mov esi, tempNumStr2
            mov ah, 0x00
            int 0xa0
            pop bx
            inc bx
            pop cx
            inc cl
            cmp cl, 0x03
            jl printInfoNum

        jmp _shellLoop

        fileNotFound2:
        mov esi, errorStr
        mov ah, 0x00
        int 0xa0

        jmp _shellLoop
        tempNumStr2 db "   ", 0x00

    _cmd3:

    jmp _shellLoop

jmp $

times 512*5 - ($-$$) db 0x00