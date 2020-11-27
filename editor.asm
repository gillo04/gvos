editor:
    call ClearScreen
    xor dx, dx
    call SetCursorPosition

    mov esi, fileNamePrompt
    call PrintString

    mov esi, fileName
    mov edi, 8
    call GetInputString

    mov esi, fileName
    call FindFile   ; search file in file list

    cmp al, 0
    je fileNotfoundError

    ; setup disk read
    mov ch, 0   ; ch = cylinder 0
    mov cl, bh   ; cl = starting sector
    mov al, bl  ; al = how many sectors to write

    ; set es:bx memory address
    mov bx, 0x7000
    mov es, bx
    mov bx, 0

    call LoadSectors

    call NewLine
    mov esi, modePrompt
    call PrintString

    call GetKeyPress
    mov ah, 0x0e
    int 0x10

    cmp al, '1'
    je hexMode


    textMode:
        call ClearScreen
        xor dx, dx
        call SetCursorPosition

        mov bx, 0x7000
        mov es, bx
        mov bx, 0
        call PrintFarString
        jmp _exit

    hexMode:
        call ClearScreen
        xor dx, dx
        call SetCursorPosition

        mov bx, 0x7000
        mov es, bx
        mov bx, 0

        

        mov ah, 0x0e
        mov cl, 16
        mov esi, 320

        hexModeLoop:
            dec esi
            cmp cl, 0
            je printNewLine
            afterNewLine:
            dec cl
            cmp cl, 7
            jne afterDSpace
            mov ah, 0x0e
            mov al, ' '
            int 0x10
            afterDSpace:

            push bx
            mov al, [es:bx]
            call HexNumberToString
            mov al, dh
            mov ah, 0x0e
            int 0x10
            mov al, dl
            int 0x10
            pop bx
            mov al, ' '
            int 0x10

            inc bx
            cmp esi, 0
            jne hexModeLoop

        jmp _exit

        printNewLine:
            push esi
            mov esi, whiteSace
            call PrintString
            sub bx, 16
            mov cl, 16
            asciiRep:
                dec cl
                mov al, [es:bx]
                cmp al, 32
                jnl afterDot
                mov al, '.'
                afterDot:
                int 0x10
                inc bx
                cmp cl, 0
                jne asciiRep

            pop esi
            mov cl, 16
            call NewLine
            jmp afterNewLine


    fileNotfoundError:
    mov esi, fileNotFoundPromp
    call PrintString

    _exit: 

    call GetKeyPress
    jmp JumpToKernel

    fileNamePrompt db "What file do you want to open? ", 0
    modePrompt db "Chose viewing mode (0 = text, 1 = hex): ", 0
    fileNotFoundPromp db 0x0a, 0x0d, "File not found.", 0
    fileName times 9 db '-'
    whiteSace db "     ", 0

%include 'string_utils.asm'
%include 'math_utils.asm'
%include 'fileSystem_utils.asm'
%include 'disk_utils.asm'

times 512*4 - ($-$$) db 0