jmp _start
%include "utils.asm"
%include "calc/calc_utils.asm"

expressionPtr dd 0x600
symbolsPtr dd 0x800
resultPtr dd 0xa00
symbolsCount db 0

tmpExpr db "45 + 6=", 0
specialCharacters db "+-*/^=()", 0

commands db "Only + and - are supported. Example: 34+4 -1 + 9                                ", 0
prompt0 db "Expression: ", 0
prompt1 db 0x0d, 0x0a, "Result: ", 0
valid db "Valid expression", 0
invalid db "Invalid expression", 0

_start:
mov ah, 0x05
int 0xa0
xor dx, dx
mov ah, 0x06
int 0xa0

mov esi, commands
InstructionLoop:
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
    jne InstructionLoop

mov bh, 0x00
mov dx, 0x0100
mov ah, 0x02
int 0x10

BeginningPrompts:

mov esi, [expressionPtr]
clearingLoop:
    mov dword[esi], 0
    add esi, 4
    mov eax, [resultPtr]
    add eax, 0x100
    cmp esi, eax
    jl clearingLoop


mov esi, prompt0
mov ah, 0x00
int 0xa0

mov esi, [expressionPtr]
mov edi, 50
mov ah, 0x02
int 0xa0

;;; --------------------------------------------------
;;; Break the expression into symbols
;;; --------------------------------------------------

mov esi, [expressionPtr]    ; Expression pointer
mov edi, [symbolsPtr]       ; Symbols pointer
mov cl, 0                   ; Symbols counter

ParserLoop:
    mov edx, specialCharacters
    mov al, [esi]

    SpecialCharLoop:
        cmp [edx], al
        je SpecialChar
        inc edx
        cmp byte[edx], 0
        jne SpecialCharLoop

    cmp byte[esi], ' '
    jne NotWhiteSpace
    cmp byte[edi-1], 0
    je WhiteSpaceLoop
    mov byte[edi], 0
    inc edi
    inc cl
    WhiteSpaceLoop:
        inc esi
        cmp byte[esi], ' '
        je WhiteSpaceLoop
        jmp NotSpecialChar

    NotWhiteSpace:
    mov [edi], al
    
    inc esi
    inc edi
    jmp NotSpecialChar

    SpecialChar:
        inc cl
        cmp byte[edi-1], 0
        je SpecialCharSeparated
        inc cl
        mov byte[edi], 0
        inc edi
        SpecialCharSeparated:
        mov [edi], al
        inc esi
        inc edi
        mov byte[edi], 0
        inc edi

    NotSpecialChar:
    
    cmp byte[esi], 0
    jne ParserLoop

    cmp byte[edi-1], 0
    je completeSymbols
    inc cl
    completeSymbols:
    mov byte[edi], 0
    mov [symbolsCount], cl

; mov esi, [symbolsPtr]
; printLoop:
;     mov ah, 0x03
;     int 0xa0
;     mov ah, 0x00
;     int 0xa0

;     inc esi
;     dec cl
;     cmp cl, 0
;     jne printLoop

;;; --------------------------------------------------
;;; Validate the expression
;;; --------------------------------------------------

mov esi, [symbolsPtr]
mov cl, [symbolsCount]
ValidateLoop:
    cmp byte[esi+1], 0
    je ValidateLoop_single
    call IsNumber
    cmp al, 0
    je ValidateLoop_fail
    inc esi
    jmp ValidateLoop_next

    ValidateLoop_single:
    add esi, 2

    ValidateLoop_next:
    dec cl
    cmp cl, 0
    jg ValidateLoop
    jmp ValidateLoop_end

ValidateLoop_fail:
mov ah, 0x03
int 0xa0

mov esi, invalid
mov ah, 0x00
int 0xa0

mov ah, 0x03
int 0xa0
jmp BeginningPrompts

ValidateLoop_end:

;;; --------------------------------------------------
;;; Solve expression
;;; --------------------------------------------------

mov esi, [symbolsPtr]

mov ah, 0x02
int 0xa1
inc esi
mov eax, ebx

mov cl, [symbolsCount]
dec cl

SolveLoop:
    mov ch, [esi]
    add esi, 2
    push cx
    push eax

    mov ah, 0x02
    int 0xa1

    pop eax
    pop cx

    cmp ch, '+'
    je SolveLoop_add
    cmp ch, '-'
    je SolveLoop_sub
    jmp ValidateLoop_fail

    SolveLoop_add:
        add eax, ebx
        jmp SolveLoop_after

    SolveLoop_sub:
        sub eax, ebx
        jmp SolveLoop_after

    SolveLoop_after:
    sub cl, 2
    inc esi
    cmp cl, 0
    jne SolveLoop

mov esi, [resultPtr]
mov ebx, eax
mov ah, 0x05
int 0xa1

mov esi, prompt1
mov ah, 0x00
int 0xa0

mov esi, [resultPtr]
mov ah, 0x00
int 0xa0

exitLoop:
    mov ah, 0x01
    int 0xa0
    cmp ax, 0x011b
    jne exitLoop

_exit:
jmp JumpToKernel

times 512*2 - ($-$$) db 0x00