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
        mov bx, 0x1000
        mov es, bx
        mov bx, 0

        loadCommandInFileNameBuffer: ; puts the file name in a variable
            inc esi
            mov al, [esi]
            cmp al, 0
            mov byte [edi], '-'
            je findFileInFilesystem
            mov [edi], al
            inc edi
            jmp loadCommandInFileNameBuffer
            
        findFileInFilesystem: ; finds where in the filesystem the file is located
            mov esi, fileNameBuffer
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
                je runFile
                inc esi
                jmp compareNextChar

        fileNotFoundStr db "File not found, chek if the name is correct.",0
        fileFoundStr db "File found in file list.",0
        startingSectorStr db 0, 0, 0
        lengthStr db 0, 0, 0
        fileNotFound:
            mov esi, fileNotFoundStr
            call PrintString
            jmp _executeCommandEnd

        runFile:
            mov esi, fileFoundStr
            call PrintString

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
            mov [startingSectorStr], al

            mov esi, lengthStr
            mov edi, 2
            call StringToNumber
            mov [lengthStr], al

            ; setup disk read
            mov ch, 0   ; ch = cylinder 0
            mov cl, [startingSectorStr]   ; cl = starting sector
            mov al, [lengthStr]   ; al = how many sectors to write

            ; set es:bx memory address
            mov bx, 0x9000
            mov es, bx
            mov bx, 0

            call LoadSectors ; load program into memory
            jmp JumpToProgram
        
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
;;; Functions and includes
;;;
    %include 'string_utils.asm'
    %include 'math_utils.asm'
    %include 'disk_utils.asm'
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

times 512*4 -($-$$) db 0