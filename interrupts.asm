;;; -------------------------------------------------------
;;;                SYSTEM DEFINED INTERRUPTS
;;; -------------------------------------------------------

;   [arguments] - (returned values)
;   #: not yet implemented

;   0xa0: I/O interrupts
;       0x00: Print null terminated string              [ESI: pointer to string, ES: data segment of string]
;       0x01: Get key press                             (AH: pressed key scan code, AL: pressed key ascii value)
;       0x02: Get input string                          [ESI: pointer to where to store the string, EDI: input length] - ([ESI]: inputted string)
;       0x03: New line
;       0x04: Backspace
;       0x05: Clear screen
;       0x06: Set cursor position                       [DH: row, DL: column]
;   0xa1: Number operations
;       0x00: Convert decimal string to 8 bit number    [ESI: pointer to null terminated string] - (BL: number, AL: set to 1 if error occurred)
;       0x01: Convert decimal string to 16 bit number   [ESI: pointer to null terminated string] - (BX: number, AL: set to 1 if error occurred)
;       0x02: Convert decimal string to 32 bit number   [ESI: pointer to null terminated string] - (EBX: number, AL: set to 1 if error occurred)
;       0x03: Convert 8 bit number to decimal string    [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x04: Convert 16 bit number to decimal string   [BX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x05: Convert 32 bit number to decimal string   [EBX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;      #0x06: Convert hex string to 8 bit number        [ESI: pointer to string] - (BL: number, AL: set to 1 if error occurred)
;       0x07: Convert 8 bit number to hex string        [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;   0xa2: File system operations
;       0x00: Load sectors into memory                  [ES:BX: destination, CH: cylinder, CL: starting sector, DH: head, DL: drive, AL: number of sectors]
;      #0x01: Save memory section on disk               [ES:BX: destination, CH: cylinder, CL: starting sector, AL: number of sectors]
;       0x02: Get file info from file name              [ESI: pointer to file name] - (CH: cylinder, CL: sector, AL: number of sectors)
;   0xb0: Graphic interrupts
;       0x00: Enter graphic mode
;       0x01: Return to previous grapich mode
;       0x02: Fill a rectangle                          [EBX: y:x, ECX: h:w, AL: color]
;       0x03: Stroke a rectangle                        [EBX: y:x, ECX: h:w, DX: stroke width, AL: color]
;       0x04: Fill a circle                             [EBX: y:x, CX: radius, AL: color]
;       0x05: Stroke a circle                           [EBX: y:x, CX: radius, DX: stroke width, AL: color]
;       0x06: Draw vector image                         [EBX: y:x, ESI: pointer to vector image definition, CX: unit size, AL: color]
;       0x07: Draw character                            [EBX: x:y, ESI: pointer to font, DL: char to draw, CX: font unit size, AL: color]
;       0x08: Draw text                                 [EBX: y:x, ESI: pointer to null rerminated string, EDI: pointer to font, CX: font unit size, DX: letter spacing, AL: color]
;       0x09: Draw line                                 [EBX: y0:x0, ECX: y1:x1, AL: color]
;      #0x0a: Render graphic definition                 [ESI: pointer to graphic definition]

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
    push dx
    push cx
    mov cl, 0
    ror cx, 8
    mov dx, cx
    and dx, 255
    shl dx, 8
    pop cx
    push cx
    push dx
    mov ch, 0
    mov dx, cx
    and dx, 768
    shr dx, 2
    pop cx
    or dx, cx
    pop cx
    mov ch, 0
    or cx, dx
    pop dx
    LoadSectors_readDisk:
        mov ah, 0x02
        int 0x13

        jc LoadSectors_readDisk

    iret
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

;;; -------------------------------------------------------
;;;                         0xB0
;;; -------------------------------------------------------
intB0:
    cmp ah, 0x00
    je EnterGraphicMode
    cmp ah, 0x01
    je ExitGraphicMode
    cmp ah, 0x02
    je FillRect
    cmp ah, 0x03
    je StrokeRect
    cmp ah, 0x04
    je FillCircle
    cmp ah, 0x05
    je StrokeCircle
    cmp ah, 0x06
    je DrawVectorImage
    cmp ah, 0x07
    je DrawChar
    cmp ah, 0x08
    je DrawText
    cmp ah, 0x09
    je DrawLine
    ; cmp ah, 0x0a
    ; je RenderDefinition
    iret



;;; ------------------------0x00---------------------------
EnterGraphicMode:
    mov ah, 0x0f
    int 0x10
    mov [prevGraphMode], al
    
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    iret
    prevGraphMode db 0

;;; ------------------------0x01---------------------------
ExitGraphicMode:
    mov ah, 0x00
    mov al, [prevGraphMode]
    int 0x10

    iret

;;; ------------------------0x02---------------------------
rectX dw 0          ; X
rectY dw 0          ; Y
rectW dw 0          ; Width
rectH dw 0          ; Height
rectC db 0          ; Color
rectSW dw 0         ; Stroke width

FillRect:
    mov [rectX], bx
    ror ebx, 16
    mov [rectY], bx

    mov [rectW], cx
    ror ecx, 16
    mov [rectH], cx

    mov [rectC], al

    mov ax, [rectW]
    add ax, [rectX]
    dec ax
    mov [rectW], ax
    mov ax, [rectH]
    add ax, [rectY]
    dec ax
    mov [rectH], ax

    mov dx, [rectY]
    FillRect_hLoop:
        mov cx, [rectX]
        FillRect_wLoop:

            ; Check if the coordinates are out of the screen bounds
            cmp cx, 0
            jl FillRect_wLoopNext
            cmp cx, SCREEN_WIDTH
            jge FillRect_wLoopNext

            cmp dx, 0
            jl FillRect_wLoopNext
            cmp dx, SCREEN_HEIGHT
            jge FillRect_wLoopNext

            ; Write pixel
            mov ah, 0x0c
            mov al, [rectC]
            mov bh, 0
            int 0x10

            FillRect_wLoopNext:
            mov ax, [rectW]
            inc cx
            cmp cx, ax
            jl FillRect_wLoop
        mov bx, [rectH]
        inc dx
        cmp dx, bx
        jl FillRect_hLoop

    iret

;;; ------------------------0x03---------------------------
StrokeRect:
    mov [rectX], bx
    ror ebx, 16
    mov [rectY], bx

    mov [rectW], cx
    ror ecx, 16
    mov [rectH], cx

    mov [rectC], al
    mov [rectSW], dx

    mov dx, [rectY]
    sub dx, [rectSW]
    StrokeRect_hLoop:
        mov cx, [rectX]
        sub cx, [rectSW]
        StrokeRect_wLoop:
            cmp dx, [rectY]
            jl StrokeRect_check
            mov ax, [rectY]
            add ax, [rectH]
            dec ax
            cmp dx, ax
            jge StrokeRect_check

            cmp cx, [rectX]
            jne StrokeRect_check
            add cx, [rectW]
            dec cx

            StrokeRect_check:
            ; Check if the coordinates are out of the screen bounds
            cmp cx, 0
            jl StrokeRect_wLoopNext
            cmp cx, SCREEN_WIDTH
            jge StrokeRect_wLoopNext

            cmp dx, 0
            jl StrokeRect_wLoopNext
            cmp dx, SCREEN_HEIGHT
            jge StrokeRect_wLoopNext

            ; Write pixel
            mov ah, 0x0c
            mov al, [rectC]
            mov bh, 0
            int 0x10

            StrokeRect_wLoopNext:
            mov ax, [rectW]
            add ax, [rectX]
            add ax, [rectSW]
            dec ax
            inc cx
            cmp cx, ax
            jl StrokeRect_wLoop
        mov bx, [rectH]
        add bx, [rectY]
        add bx, [rectSW]
        dec bx
        inc dx
        cmp dx, bx
        jl StrokeRect_hLoop

    iret
    
;;; ------------------------0x04---------------------------
FillCircle:
    mov [rectX], bx
    ror ebx, 16
    mov [rectY], bx
    ror ebx, 16

    mov [rectW], cx
    mov [rectC], al

    mov dx, [rectY]
    sub dx, [rectW]
    FillCircle_hLoop:
        mov cx, [rectX]
        sub cx, [rectW]
        FillCircle_wLoop:
            ; Check if the coordinates are out of the screen bounds
            cmp cx, 0
            jl FillCircle_notDraw
            cmp cx, SCREEN_WIDTH
            jge FillCircle_notDraw

            cmp dx, 0
            jl FillCircle_notDraw
            cmp dx, SCREEN_HEIGHT
            jge FillCircle_notDraw

            push cx
            push dx

            sub cx, [rectX]
            mov ax, cx
            mul cx
            mov cx, ax

            pop dx
            push dx

            sub dx, [rectY]
            mov ax, dx
            mul dx
            mov dx, ax

            add cx, dx
            mov bx, cx
            mov ax, [rectW]
            mul ax
            pop dx
            pop cx
            cmp bx, ax
            jge FillCircle_notDraw

            ; Write pixel
            mov ah, 0x0c
            mov al, [rectC]
            mov bh, 0
            int 0x10

            FillCircle_notDraw:
            inc cx
            mov ax, [rectW]
            add ax, [rectX]
            cmp cx, ax
            jl FillCircle_wLoop
        inc dx
        mov ax, [rectW]
        add ax, [rectY]
        cmp dx, ax
        jl FillCircle_hLoop

    iret

;;; ------------------------0x05---------------------------
StrokeCircle:
    mov [rectX], bx
    ror ebx, 16
    mov [rectY], bx
    ror ebx, 16

    mov [rectW], cx
    mov [rectSW], dx
    mov [rectC], al

    mov dx, [rectY]
    sub dx, [rectW]
    sub dx, [rectSW]
    StrokeCircle_hLoop:
        mov cx, [rectX]
        sub cx, [rectW]
        sub cx, [rectSW]
        StrokeCircle_wLoop:
            ; Check if the coordinates are out of the screen bounds
            cmp cx, 0
            jl StrokeCircle_next
            cmp cx, SCREEN_WIDTH
            jge StrokeCircle_next

            cmp dx, 0
            jl StrokeCircle_next
            cmp dx, SCREEN_HEIGHT
            jge StrokeCircle_next

            push cx
            push dx

            sub cx, [rectX]
            mov ax, cx
            mul cx
            mov cx, ax

            pop dx
            push dx

            sub dx, [rectY]
            mov ax, dx
            mul dx
            mov dx, ax

            add cx, dx
            mov bx, cx
            mov ax, [rectW]
            add ax, [rectSW]
            mul ax

            cmp bx, ax
            jge StrokeCircle_notDraw

            mov ax, [rectW]
            mul ax
            cmp bx, ax
            jl StrokeCircle_notDraw

            pop dx
            pop cx
            ; Write pixel
            mov ah, 0x0c
            mov al, [rectC]
            mov bh, 0
            int 0x10

            jmp StrokeCircle_next

            StrokeCircle_notDraw:
            pop dx
            pop cx
            StrokeCircle_next:
            inc cx
            mov ax, [rectW]
            add ax, [rectX]
            add ax, [rectSW]
            cmp cx, ax
            jl StrokeCircle_wLoop
        inc dx
        mov ax, [rectW]
        add ax, [rectY]
        add ax, [rectSW]
        cmp dx, ax
        jl StrokeCircle_hLoop

    iret

;;; ------------------------0x06---------------------------
DrawVectorImage:
    mov [vimgS], cx
    mov [vimgC], al

    mov [vimgX], bx
    ror ebx, 16
    mov [vimgY], bx

    mov eax, 0
    mov al, [esi]
    inc esi
    mov edi, esi
    add al, al
    add edi, eax

    mov al, [edi]
    mov [vimgCN], al

    DrawVectorImage_loop:
        xor ebx, ebx
        xor ecx, ecx
        xor eax, eax

        inc edi
        mov al, [edi]
        mov bl, [eax*2 + esi + 1]
        mov ax, [vimgS]
        mul bx
        mov bx, ax
        add bx, [vimgY]

        ror ebx, 16
        mov al, [edi]
        mov bl, [eax*2 + esi]
        mov ax, [vimgS]
        mul bx
        mov bx, ax
        add bx, [vimgX]


        inc edi
        mov al, [edi]
        mov cl, [eax*2 + esi + 1]
        mov ax, [vimgS]
        mul cx
        mov cx, ax
        add cx, [vimgY]

        ror ecx, 16
        mov al, [edi]
        mov cl, [eax*2 + esi]
        mov ax, [vimgS]
        mul cx
        mov cx, ax
        add cx, [vimgX]

        mov ah, 0x09
        mov al, [vimgC]
        int 0xb0

        dec byte [vimgCN]
        cmp byte [vimgCN], 0
        jg DrawVectorImage_loop

    iret

    vimgCN db 0
    vimgS dw 0
    vimgC db 0
    vimgX dw 0
    vimgY dw 0

;;; ------------------------0x07---------------------------
DrawChar:
    sub dl, 'A'
    cmp dl, 0
    jl DrawChar_exit

    push ax
    xor eax, eax
    DrawChar_loop:
        cmp dl, 0
        jle DrawChar_draw
        mov ax, [esi]
        add esi, eax
        dec dl
        jmp DrawChar_loop

    DrawChar_draw:
    pop ax
    add esi, 2
    mov ah, 0x06
    int 0xb0

    DrawChar_exit:

    iret

;;; ------------------------0x08---------------------------
DrawText:
    DrawText_loop:
        push ax
        push edi
        push esi
        push ebx
        push cx
        push dx

        mov dl, [esi]
        mov esi, edi
        mov ah, 0x07
        int 0xb0

        pop dx
        pop cx
        pop ebx
        pop esi
        pop edi

        add bx, dx

        pop ax

        inc esi
        cmp byte[esi], 0
        jne DrawText_loop

    iret

;;; ------------------------0x09---------------------------
DrawLine:
    mov [rectC], al
    mov [rectX], bx
    ror ebx, 16
    mov [rectY], bx

    mov [lineX1], cx
    ror ecx, 16
    mov [lineY1], cx
    
    ; Reorder positions
    
    ; DX and DY
    mov ax, [lineX1]
    sub ax, [rectX]
    call MathAbs
    mov [lineDX], ax
    
    mov ax, [lineY1]
    sub ax, [rectY]
    call MathAbs
    not ax
    inc ax
    mov [lineDY], ax

    ; SX and SY
    mov word[lineSX], 1
    mov ax, [rectX]
    cmp ax, [lineX1]
    jl DrawLine_SX
    mov word[lineSX], -1
    DrawLine_SX:

    mov word[lineSY], 1
    mov ax, [rectY]
    cmp ax, [lineY1]
    jl DrawLine_SY
    mov word[lineSY], -1
    DrawLine_SY:

    mov bx, [lineDX]    ; Error
    add bx, [lineDY]

    mov cx, [rectX]
    mov dx, [rectY]
    DrawLine_loop:
        ; Check if the coordinates are out of the screen bounds
        cmp cx, 0
        jl DrawLine_continue
        cmp cx, SCREEN_WIDTH
        jge DrawLine_continue

        cmp dx, 0
        jl DrawLine_continue
        cmp dx, SCREEN_HEIGHT
        jge DrawLine_continue

        ; Write pixel
        push bx
        mov ah, 0x0c
        mov al, [rectC]
        mov bh, 0
        int 0x10
        pop bx
        

        cmp cx, [lineX1]
        jne DrawLine_continue
        cmp dx, [lineY1]
        je DrawLine_exit
        DrawLine_continue:
        mov ax, bx
        add ax, bx
        
        cmp ax, [lineDY]
        jl DrawLine_checkDY
            add bx, [lineDY]
            add cx, [lineSX]
        DrawLine_checkDY:
        
        cmp ax, [lineDX]
        jg DrawLine_checkDX
            add bx, [lineDX]
            add dx, [lineSY]
        DrawLine_checkDX:

        jmp DrawLine_loop

    DrawLine_exit:
    iret

    lineX1 dw 0
    lineY1 dw 0

    lineDX dw 0
    lineDY dw 0
    lineSX dw 1
    lineSY dw 1

MathAbs: ; AX: number
    cmp ax, 0
    jg MathAbs_exit

    not ax
    inc ax

    MathAbs_exit:
    ret

times 512*5 - ($-$$) db 0x00    ; 4 sectors + 1 to account for the bootloader size