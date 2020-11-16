org 0x7c00
jmp _start
; Data section
    greetingMsg db "Welcome to GVOS2. Type help to get a guide.", 0x08, 0x20, 0x0a, 0x0d, 0
    command db 0, 0, 0, 0, 0, 0
    
    s_help db "help", 0

; Code section
_start:

    mov esi, greetingMsg
    call PrintString

_mainLoop:
    call NewLine

    mov esi, command
    mov ah, 0x0e ; print >
    mov al, 0x3e
    int 0x10
_getCommandLoop: ; Get and execute command routine
    call GetKeyPress
    cmp al, 0x0d
    je _executeCommand

    cmp al, 0x08
    je _backSpace
    
    sub esi, command
    cmp esi, 5
    jge _bufferFull
    add esi, command
    
    _addChar:
        mov [esi], al
        mov ah, 0x0e
        int 0x10
        inc esi
        jmp _getCommandLoop

    _backSpace:
        cmp esi, command
        je _getCommandLoop
        dec esi
        mov byte [esi], 0x00
        call BackSpace
        jmp _getCommandLoop
    
    _bufferFull:
        add esi, command
        jmp _getCommandLoop

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

; Functions
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

; Commands
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

times 510-($-$$) db 0
db 0x55, 0xaa