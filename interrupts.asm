;;; -------------------------------------------------------
;;;                SYSTEM DEFINED INTERRUPTS
;;; -------------------------------------------------------

;   [arguments] - (returned values)
;   #: not yet implemented

;   0xa0: I/O interrupts
;       0x00: Print null terminated string [ESI: pointer to string, ES: data segment of string]
;       0x01: Get key press (AH: pressed key scan code, AL: pressed key ascii value)
;       0x02: Get input string [ESI: pointer to where to store the string, EDI: input length] - ([ESI]: inputted string)
;       0x03: New line
;       0x04: Backspace
;       0x05: Clear screen
;       0x06: Set cursor position [DH: row, DL: column]
;   0xa1: Number operations
;       0x00: Convert decimal string to 8 bit number [ESI: pointer to null terminated string] - (BL: number, AL: set to 1 if error occurred)
;       0x01: Convert decimal string to 16 bit number [ESI: pointer to null terminated string] - (BX: number, AL: set to 1 if error occurred)
;       0x02: Convert decimal string to 32 bit number [ESI: pointer to null terminated string] - (EBX: number, AL: set to 1 if error occurred)
;       0x03: Convert 8 bit number to decimal string [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x04: Convert 16 bit number to decimal string [BX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x05: Convert 32 bit number to decimal string [EBX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;      #0x06: Convert hex string to 8 bit number [ESI: pointer to string] - (BL: number, AL: set to 1 if error occurred)
;       0x07: Convert 8 bit number to hex string [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;   0xa2: File system operations
;       0x00: Load sectors into memory [ES:BX: destination, CH: cylinder, CL: starting sector, AL: number of sectors]
;      #0x01: Save memory section on disk [ES:BX: destination, CH: cylinder, CL: starting sector, AL: number of sectors]
;       0x02: Get file info from file name [ESI: pointer to file name] - (CH: cylinder, CL: sector, AL: number of sectors)
;   0xa3: Graphic interrupts            !NOT FINISHED!
;      #0x00: Enter graphic mode
;      #0x01: Exit grapich mode
;      #0x02: Fill a rectangle
;      #0x03: Stroke a rectangle
;      #0x04: Fill a circle
;      #0x05: Stroke a circle
;      #0x06: Draw text

;;; -------------------------------------------------------
;;;                         0xA0
;;; -------------------------------------------------------
intA0:
    cmp ah, 0x00
    je PrintString
    cmp ah, 0x01
    je GetKeyPress
    cmp ah, 0x02
    je GetInputString
    cmp ah, 0x03
    je NewLine
    cmp ah, 0x04
    je BackSpace
    cmp ah, 0x05
    je ClearScreen
    cmp ah, 0x06
    je SetCursorPosition
    iret

;;; ------------------------0x00---------------------------
PrintString:
    mov ah, 0x0e
    PrintString_loop:
        mov al, [esi]
        int 0x10
        inc esi
        cmp byte [esi], 0
        jne PrintString_loop
    iret

jmp $

;;; ------------------------0x01---------------------------
GetKeyPress:
    mov ah, 0x00
    _GetKeyPressloop0:
        int 0x16
        cmp al, 0x00
        je _GetKeyPressloop0

    iret

;;; ------------------------0x02---------------------------
GetInputString:
    mov edx, esi

    GetInputStringLoop0:
        mov ah, 0x01
        int 0xa0
        cmp al, 0x0d
        je GetInputStringExit

        cmp al, 0x08
        je GetInputStringBackSpace
        
        sub esi, edx
        cmp esi, edi
        jge GetInputStringBufferFull
        add esi, edx
        
        ;_addChar:
            mov [esi], al
            mov ah, 0x0e
            int 0x10
            inc esi
            jmp GetInputStringLoop0

        GetInputStringBackSpace:
            cmp esi, edx
            je GetInputStringLoop0
            dec esi
            mov byte [esi], 0x00
            mov ah, 0x04
            int 0xa0        ; BackSpace
            jmp GetInputStringLoop0
        
        GetInputStringBufferFull:
            add esi, edx
            jmp GetInputStringLoop0

    GetInputStringExit:

    iret

;;; ------------------------0x03---------------------------
NewLine:
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    iret

;;; ------------------------0x04---------------------------
BackSpace:
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10
    iret

;;; ------------------------0x05---------------------------
ClearScreen:
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x1950
    int 0x10

    iret

;;; ------------------------0x06---------------------------
SetCursorPosition: ; DH: row, DL: column
    mov ah, 0x02
    mov bh, 0
    int 0x10

    iret



;;; -------------------------------------------------------
;;;                         0xA1
;;; -------------------------------------------------------
intA1:
    cmp ah, 0x00
    je DecStrToNum8
    cmp ah, 0x01
    je DecStrToNum16
    cmp ah, 0x02
    je DecStrToNum32
    cmp ah, 0x03
    je NumToDecStr8
    cmp ah, 0x04
    je NumToDecStr16
    cmp ah, 0x05
    je NumToDecStr32
    cmp ah, 0x07
    je NumToHexStr8
    iret

;;; ------------------------0x00---------------------------
DecStrToNum8:
    cmp byte[esi], 0
    je DecStrToNum8_error
    mov cl, 0       ; String size
    mov bl, 0       ; Final result

    push esi
    DecStrToNum8_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum8_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum8_error
        cmp byte[esi], '9'
        jg DecStrToNum8_error
        inc esi
        inc cl
        cmp cl, 3
        jg DecStrToNum8_error
        jmp DecStrToNum8_reachEnd

    DecStrToNum8_addPreLoop:
        pop esi
    DecStrToNum8_addLoop:
        mov al, 1
        push cx
        DecStrToNum8_powerLoop:
            cmp cl, 1
            je DecStrToNum8_powerLoopEnd
            mov dl, 10
            mul dl
            dec cl
            jmp DecStrToNum8_powerLoop
        DecStrToNum8_powerLoopEnd:
        pop cx
        mov dl, [esi]
        sub dl, 48
        mul dl
        add bl, al
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum8_exit
        jmp DecStrToNum8_addLoop

    DecStrToNum8_error:
        mov al, 1
        iret

    DecStrToNum8_exit:
        mov al, 0
        iret

;;; ------------------------0x01---------------------------
DecStrToNum16:
    cmp byte[esi], 0
    je DecStrToNum16_error
    mov cl, 0       ; String size
    mov bx, 0       ; Final result

    push esi
    DecStrToNum16_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum16_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum16_error
        cmp byte[esi], '9'
        jg DecStrToNum16_error
        inc esi
        inc cl
        cmp cl, 5
        jg DecStrToNum16_error
        jmp DecStrToNum16_reachEnd

    DecStrToNum16_addPreLoop:
        pop esi
    DecStrToNum16_addLoop:
        mov ax, 1
        push cx
        DecStrToNum16_powerLoop:
            cmp cl, 1
            je DecStrToNum16_powerLoopEnd
            mov dx, 10
            mul dx
            dec cl
            jmp DecStrToNum16_powerLoop
        DecStrToNum16_powerLoopEnd:
        pop cx
        mov dh, 0
        mov dl, [esi]
        sub dl, 48
        mul dx
        add bx, ax
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum16_exit
        jmp DecStrToNum16_addLoop

    DecStrToNum16_error:
        mov al, 1
        iret

    DecStrToNum16_exit:
        mov al, 0
        iret

;;; ------------------------0x02---------------------------
DecStrToNum32:
    cmp byte[esi], 0
    je DecStrToNum32_error
    mov cl, 0       ; String size
    mov ebx, 0       ; Final result

    push esi
    DecStrToNum32_reachEnd:
        cmp byte[esi], 0
        je DecStrToNum32_addPreLoop
        cmp byte[esi], '0'
        jl DecStrToNum32_error
        cmp byte[esi], '9'
        jg DecStrToNum32_error
        inc esi
        inc cl
        cmp cl, 10
        jg DecStrToNum32_error
        jmp DecStrToNum32_reachEnd

    DecStrToNum32_addPreLoop:
        pop esi
    DecStrToNum32_addLoop:
        mov eax, 1
        push cx
        DecStrToNum32_powerLoop:
            cmp cl, 1
            je DecStrToNum32_powerLoopEnd
            mov edx, 10
            mul edx
            dec cl
            jmp DecStrToNum32_powerLoop
        DecStrToNum32_powerLoopEnd:
        pop cx
        mov edx, 0
        mov dl, [esi]
        sub dl, 48
        mul edx
        add ebx, eax
        dec cl
        inc esi
        cmp cl, 0
        je DecStrToNum32_exit
        jmp DecStrToNum32_addLoop

    DecStrToNum32_error:
        mov al, 1
        iret

    DecStrToNum32_exit:
        mov al, 0
        iret

;;; ------------------------0x03---------------------------
NumToDecStr8:
    mov ah, 0
    mov al, bl
    mov edi, esi

    NumToDecStr8_loop:
        mov dl, 10
        div dl
        add ah, 48
        mov [esi], ah
        inc esi
        mov ah, 0
        cmp al, 0
        jne NumToDecStr8_loop

    NumToDecStr8_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr8_reverseString

    iret

;;; ------------------------0x04---------------------------
NumToDecStr16:
    mov dx, 0
    mov ax, bx
    mov edi, esi

    NumToDecStr16_loop:
        mov bx, 10
        div bx
        add dl, 48
        mov [esi], dl
        inc esi
        mov dx, 0
        cmp ax, 0
        jne NumToDecStr16_loop

    NumToDecStr16_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr16_reverseString

    iret

;;; ------------------------0x05---------------------------
NumToDecStr32:
    mov edx, 0
    mov eax, ebx
    mov edi, esi

    NumToDecStr32_loop:
        mov ebx, 10
        div ebx
        add dl, 48
        mov [esi], dl
        inc esi
        mov edx, 0
        cmp eax, 0
        jne NumToDecStr32_loop

    NumToDecStr32_reverseString:
        dec esi
        mov al, [esi]
        mov ah, [edi]
        mov [edi], al
        mov [esi], ah
        inc edi
        cmp esi, edi
        jg NumToDecStr32_reverseString
    
    iret

;;; ------------------------0x06---------------------------


;;; ------------------------0x07---------------------------
NumToHexStr8:
    mov cl, 0
    NumToHexStr8_loop:
        ror bl, 4
        push bx
        and bl, 0x0f
        cmp bl, 9
        jg NumToHexStr8_letter
        add bl, 48
        jmp NumToHexStr8_letter_end
        NumToHexStr8_letter:
        add bl, 65-10
        NumToHexStr8_letter_end:
        mov [esi], bl
        pop bx
        inc esi
        inc cl
        cmp cl, 2
        jne NumToHexStr8_loop

    iret

;;; -------------------------------------------------------
;;;                         0xA2
;;; -------------------------------------------------------
intA2:
    cmp ah, 0x00
    je LoadSectors
    ; cmp ah, 0x01
    ; je GetKeyPress
    cmp ah, 0x02
    je GetFileInfo
    iret

;;; ------------------------0x00---------------------------
LoadSectors:
    xor dx, dx
    LoadSectors_readDisk:
        mov ah, 0x02
        int 0x13

        jc LoadSectors_readDisk

    iret
debugStr db "Lmao", 0
;;; ------------------------0x01---------------------------
; work in progress

;;; ------------------------0x02---------------------------
GetFileInfo:
    mov bx, FILE_LIST_SEGMENT
    mov es, bx
    mov bx, FILE_LIST_ADDR

    push bx
    push esi
    mov cx, 10
    GetFileInfo_matchLoop:
        dec cx

        mov al, [esi]
        cmp al, [es:bx]
        jne GetFileInfo_noMatch

        inc bx
        inc esi
        cmp byte [es:bx], ' '
        jne GetFileInfo_checkZeroEnd
        cmp byte [esi], 0
        je GetFileInfo_match
        GetFileInfo_checkZeroEnd:
        cmp cx, 0
        je GetFileInfo_match
        jmp GetFileInfo_matchLoop

    GetFileInfo_noMatch:
        pop esi
        pop bx
        add bx, 13
        cmp byte [es:bx], 0
        je GetFileInfo_notFound
        push bx
        push esi
        mov cx, 10
        jmp GetFileInfo_matchLoop

    GetFileInfo_match:
        pop esi
        pop bx

        add bx, 10
        mov ch, [es:bx]
        mov cl, [es:bx+1]
        mov al, [es:bx+2]

        jmp GetFileInfo_exit

    GetFileInfo_notFound:
        mov al, 0

    GetFileInfo_exit:
    iret

times 512*3 - ($-$$) db 0x00    ; 2 sectors + 1 to account for the bootloader size