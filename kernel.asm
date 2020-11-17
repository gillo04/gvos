jmp _start
; Data section
    greetingMsg db "Welcome to GVOS. Type 'help' to get a guide.", 0x0a, 0x0d, 0
    command db 0, 0, 0, 0, 0, 0
    
    s_help db "help", 0
    s_calc db "calc", 0

; Code section
_start:

    mov esi, greetingMsg
    call PrintString

_mainLoop:
    ;TODO: clear command address
    call NewLine

    mov ah, 0x0e ; print >
    mov al, 0x3e
    int 0x10

    mov esi, command
    mov edi, 5
    call GetInputString

_executeCommand:
    call NewLine

    mov esi, command
    mov edi, s_help
    call CompareStrings
    cmp al, 1
    jne CM1
    call Cm_help
    jmp _executeCommandEnd

    CM1:

_executeCommandEnd: 
    jmp _mainLoop

_exit:
    jmp $

;;;
;;; Functions and includes
;;;
    %include 'standard_functions.asm'
;;;
;;; Commands
;;;
Cm_help:
    push ebp
    mov ebp, esp

    jmp Cm_help0
    HelpStr0 db "For now there are no commands except for 'help'.",0

    Cm_help0:
    mov esi, HelpStr0
    call PrintString

    mov esp, ebp
    pop ebp
    ret

Cm_calc:
    push ebp
    mov ebp, esp

    jmp Cm_calc0
    CalcStr0 db "Number 1: ", 0
    CalcStr1 db "Operand: ", 0
    CalcStr2 db "Number 2: ", 0

    CalcVar0 db 0, 0, 0, 0, 0, 0
    CalcVar1 db 0
    CalcVar2 db 0, 0, 0, 0, 0, 0

    Cm_calc0:
        ; get the inputs
        mov esi, CalcStr0
        call PrintString

        mov esi, CalcVar0
        mov edi, 5
        call GetInputString

        call NewLine
        mov esi, CalcStr2
        call PrintString

        mov esi, CalcVar2
        mov edi, 5
        call GetInputString

        ; calculate and output
        call NewLine
        mov esi, CalcVar0
        call PrintString

    mov esp, ebp
    pop ebp
    ret

    
times 512*2 -($-$$) db 0