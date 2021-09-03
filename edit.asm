jmp _start
%include "utils.asm"

_start:
mov ah, 0x05
int 0xa0
xor dx, dx
mov ah, 0x06
int 0xa0

mov esi, prompt0
mov ah, 0x00
int 0xa0

fileFindLoop:
    mov esi, fileName
    clearShellString:
        mov byte[esi], 0
        inc esi
        cmp byte[esi], 0
        jne clearShellString
    mov esi, fileName
    mov edi, 20
    mov ah, 0x02
    int 0xa0

    ; Load the file
    mov esi, fileName
    mov ah, 0x02
    int 0xa2
    cmp al, 0
    je fileNotFound

    mov [fileSize], al

    mov bx, PROGRAM_SEGMENT
    mov es, bx
    mov bx, 0x600
    mov ah, 0x00
    int 0xa2

    jmp interprete

    fileNotFound:
    mov esi, fileNotFoundStr
    mov ah, 0x00
    int 0xa0
    jmp fileFindLoop

interprete:
    mov esi, prompt1
    mov ah, 0x00
    int 0xa0
    mov ah, 0x01
    int 0xa0

    cmp al, '0'
    je asciiInterpretation
    cmp al, '1'
    je hexInterpretation

hexInterpretation:
    mov ax, PROGRAM_SEGMENT
    mov es, ax
    mov bx, 0x600
    mov di, 0x750
    hexInterpretation_mainLoop:
        push bx
        mov ah, 0x05
        int 0xa0
        xor dx, dx
        mov ah, 0x06
        int 0xa0
        
        mov esi, commands
        hexInstructionLoop:
            mov ah, 0x09
            mov al, [esi]
            mov bh, 0
            mov bl, 0x70
            mov cx, 1
            int 0x10

            mov bh, 0x00
            mov ah, 0x03
            int 0x10
            inc dl
            mov bh, 0x00
            mov ah, 0x02
            int 0x10

            inc esi
            cmp byte [esi], 0
            jne hexInstructionLoop

        mov bh, 0x00
        mov dx, 0x0100
        mov ah, 0x02
        int 0x10

        mov esi, header
        mov ah, 0x00
        int 0xa0
        
        ; mov ax, PROGRAM_SEGMENT
        ; mov es, ax
        ; mov bx, 0x600
        ; mov di, 0x750
        pop bx
        mov cl, 0
        hexInterpretation_outLoop:
            push bx
            push cx

            cmp cl, 0
            jne noLineInd

            sub bx, 0x600
            mov esi, hexLineTmp+2
            mov ah, 0x07
            int 0xa1
            mov bl, bh
            mov esi, hexLineTmp
            mov ah, 0x07
            int 0xa1
            mov esi, hexLineTmp
            mov ah, 0x00
            int 0xa0
            mov al, ' '
            int 0x10
            int 0x10
            noLineInd:
            pop cx
            pop bx
            push bx
            push cx

            mov ah, 0x07
            mov bl, [es:bx]
            mov esi, hexRepTmp
            int 0xa1

            mov ah, 0x0e
            mov al, [hexRepTmp]
            int 0x10
            mov al, [hexRepTmp+1]
            int 0x10
            mov al, ' '
            int 0x10

            pop cx
            pop bx
            inc bx
            inc cl
            cmp cl, 8
            jne noSpace
            int 0x10
            int 0x10
            noSpace:
                cmp cl, 16
                jne noLineBeak
                int 0x10
                int 0x10
                mov cl, 0
                sub bx, 0x10
                
                hexAsciiLoop:
                    mov al, [es:bx]
                    cmp al, 32
                    jge notDot
                    mov al, '.'
                    notDot:
                    int 0x10
                    inc cl
                    inc bx
                    cmp cl, 16
                    jl hexAsciiLoop
                mov cl, 0
                
                mov ah, 0x03
                int 0xa0
            noLineBeak:

            cmp bx, di
            jl hexInterpretation_outLoop

        sub bx, 0x150

        hexKeyboardCommands:
        mov ah, 0x01
        int 0xa0
        cmp al, 's'
        je hexScrollDown
        cmp al, 'w'
        je hexScrollUp
        cmp al, 'x'
        je _exit
        jmp hexInterpretation_mainLoop
        hexScrollDown:
            mov ax, 0x200
            mov cx, [fileSize]
            mul cx
            add ax, 0x600
            cmp di, ax
            je hexKeyboardCommands
            add bx, 0x10
            add di, 0x10
            jmp hexInterpretation_mainLoop
        hexScrollUp:
            cmp bx, 0x600
            je hexKeyboardCommands
            sub bx, 0x10
            sub di, 0x10
            jmp hexInterpretation_mainLoop

    jmp exitLoop
    
    hexRepTmp db "00", 0
    hexLineTmp db "0000", 0

;-------------------------------------------------------
asciiInterpretation:
    mov ah, 0x05
    int 0xa0
    xor dx, dx
    mov ah, 0x06
    int 0xa0

    mov esi, commands
    asciiInstructionLoop:
        mov ah, 0x09
        mov al, [esi]
        mov bh, 0
        mov bl, 0x70
        mov cx, 1
        int 0x10

        mov bh, 0x00
        mov ah, 0x03
        int 0x10
        inc dl
        mov bh, 0x00
        mov ah, 0x02
        int 0x10

        inc esi
        cmp byte [esi], 0
        jne asciiInstructionLoop
    
    mov bh, 0x00
    mov dx, 0x0100
    mov ah, 0x02
    int 0x10

    mov ax, PROGRAM_SEGMENT
    mov es, ax
    mov bx, 0x600

    asciiPrintLoop:
        mov ah, 0x0e
        mov al, [es:bx]
        int 0x10
        inc bx
        cmp byte[es:bx], 0x00
        jne asciiPrintLoop

    exitLoop:
        mov ah, 0x01
        int 0xa0
        cmp al, 'x'
        jne exitLoop

_exit:
jmp JumpToKernel

fileName times 20 db 0
fileSize db 0

prompt0 db "Insert the file you want to edit: ", 0x00
fileNotFoundStr db 0x0d, 0x0a, "File not found, try again: ", 0x00
prompt1 db 0x0d, 0x0a, "How do you want to view the file? (0: ascii, 1: hex)", 0x00
header db "      00 01 02 03 04 05 06 07   08 09 0A 0B 0C 0D 0E 0F   _____ascii______",0x0d, 0x0a, 0x0d, 0x0a, 0
commands db "X: quit | W: scroll up | S: scroll down                                         ", 0

times 512*2 - ($-$$) db 0x00