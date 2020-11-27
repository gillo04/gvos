jmp _start
; Data section
    greetingMsg db 218, "----------------------------------------------", 191, 0x0a, 0x0d
                db "| Welcome to GVOS. Type 'help' to get a guide. |", 0x0a, 0x0d
                db 192, "----------------------------------------------", 217, 0x0a, 0x0d, 0
    command times 11 db 0
    fileNameBuffer times 9 db 0

    s_help db "help", 0

; Code section
_start:

    call ClearScreen
    xor dx, dx
    call SetCursorPosition

    mov esi, greetingMsg
    call PrintString

_mainLoop:

    mov esi, command
    mov ah, 10
    mov al, 0
    call FillString

    mov esi, fileNameBuffer
    mov ah, 8
    mov al, 0
    call FillString

    call NewLine

    mov ah, 0x0e ; print >
    mov al, 0x3e
    int 0x10

    mov esi, command
    mov edi, 10
    call GetInputString

_executeCommand:
    call NewLine

    CM0:
    mov esi, command
    mov edi, s_help
    call CompareStrings
    cmp al, 1
    jne CM1
    call Cm_help
    jmp _executeCommandEnd

    CM1:
    mov esi, command
    mov al, [esi]
    cmp al, 'R'
    jne CM2
        inc esi
        mov edi, fileNameBuffer

        loadCommandInFileNameBuffer: ; puts the file name in a variable
            inc esi
            mov al, [esi]
            cmp al, 0
            mov byte [edi], '-'
            je findTheFile
            mov [edi], al
            inc edi
            jmp loadCommandInFileNameBuffer

        findTheFile:
        mov esi, fileNameBuffer
        call FindFile

        cmp al, 0
        je fileNotFoundError
            
        ; setup disk read
        mov ch, 0   ; ch = cylinder 0
        mov cl, bh   ; cl = starting sector
        mov al, bl  ; al = how many sectors to write

        ; set es:bx memory address
        mov bx, 0x9000
        mov es, bx
        mov bx, 0

        call LoadSectors ; load program into memory
        jmp JumpToProgram
        
        fileNotFoundStr db "File not found, chek if the name is correct.",0
        fileNotFoundError:
            mov esi, fileNotFoundStr
            call PrintString

    jmp _executeCommandEnd

    CM2:
    mov esi, command
    mov al, [esi]
    cmp al, 'T'
    jne CM3
        mov bx, 0x1000
        mov es, bx
        mov bx, 0
        mov ah, 0x0e

        mov esi, fileTableHeader
        call PrintString

        mov cl, 2
        ;mov ch, 8

        fileTableDrawingLoop:
            mov al, [es:bx]
            inc bx
            cmp al, 0
            je _executeCommandEnd
            cmp al, '|'
            je newFileDef
            cmp al, '-'
            je dash
            dec ch
            int 0x10
            jmp fileTableDrawingLoop
            
        newFileDef:
            mov ch, 8
            call NewLine
            mov al, ' '
            int 0x10
            jmp fileTableDrawingLoop
        dash:
            dec cl
            cmp cl, 0
            je dash2
            mov al, ' '
            dashLoop:
                int 0x10
                cmp ch, 0
                je fileTableDrawingLoop
                dec ch
                jmp dashLoop
            jmp fileTableDrawingLoop
            dash2:
                mov esi, whiteSpace
                call PrintString
                mov cl, 2
                jmp fileTableDrawingLoop
        whiteSpace db "   ", 0
        fileTableHeader db " Name     Sart Length", 0

    jmp _executeCommandEnd

    CM3:

_executeCommandEnd:
    jmp _mainLoop

_exit:
    jmp $

;;;
;;; Commands
;;;
Cm_help:
    push ebp
    mov ebp, esp

    jmp Cm_help0
    HelpStr0 db "- R <program name>: loads and runs the program specified", 0x0a, 0x0d
             db "- T: prints the file table", 0

    Cm_help0:
    mov esi, HelpStr0
    call PrintString

    mov esp, ebp
    pop ebp
    ret

;;;
;;; Functions and includes
;;;
    %include 'string_utils.asm'
    %include 'math_utils.asm'
    %include 'disk_utils.asm'
    %include 'fileSystem_utils.asm'

times 512*4 -($-$$) db 0