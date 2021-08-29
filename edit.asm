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
    
    hexPrintPhase:
    push bx
    mov ah, 0x05
    int 0xa0
    xor dx, dx
    mov ah, 0x06
    int 0xa0

    mov cl, 1
    hexPrintLoop:
        push bx
        push cx
        mov esi, hexRepTmp
        mov ax, [es:bx]
        call NumberToHex

        mov esi, hexRepTmp
        mov ah, 0x00
        int 0xa0

        mov al, ' '
        mov ah, 0x0e
        int 0x10
        pop cx
        cmp cl, 8
        jne noDoubleSpace
            int 0x10
        noDoubleSpace:
        cmp cl, 16
        jne noNewLine
            mov ah, 0x03
            int 0xa0
            mov cl, 0
        noNewLine:

        pop bx
        inc bx
        inc cl
        cmp bx, 8*2*24 ; number of bytes to print
        jl hexPrintLoop

    hexInputLoop:
    pop bx
    mov ah, 0x01
    int 0xa0
    cmp al, 'w'
    je hexScrollUp
    cmp al, 's'
    je hexScrollDown
    cmp al, 'x'
    je _exit
    jmp hexInputLoop
    hexScrollUp:
        mov cl, 1
        cmp bx, 0
        je hexInputLoop
        sub bx, 16
        jmp hexPrintPhase
    hexScrollDown:
        mov cl, 1
        add bx, 16
        jmp hexPrintPhase
    
    hexRepTmp db "00", 0
asciiInterpretation:
    mov ah, 0x05
    int 0xa0
    xor dx, dx
    mov ah, 0x06
    int 0xa0

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

    mov ah, 0x01
    int 0xa0

_exit:

jmp JumpToKernel

fileName times 20 db 0

prompt0 db "Insert the file you want to edit: ", 0x00
fileNotFoundStr db 0x0d, 0x0a, "File not found, try again: ", 0x00
prompt1 db 0x0d, 0x0a, "How do you want to view the file? (0: ascii, 1: hex)", 0x00

times 512*2 - ($-$$) db 0x00