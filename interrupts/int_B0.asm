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
    ;dec ax
    mov [rectW], ax
    mov ax, [rectH]
    add ax, [rectY]
    ;dec ax
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
            ;dec ax
            inc cx
            cmp cx, ax
            jl StrokeRect_wLoop
        mov bx, [rectH]
        add bx, [rectY]
        add bx, [rectSW]
        ;dec bx
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

;;; ------------------------0x0a---------------------------
; TYPES:
;   0: Rectangle
;       dw x, y, w, h
;       db color
;   1: Rectangle border
;       dw x, y, w, h
;       dw stroke_witdth
;       db color
;   2: Rectangle with border
;       dw x, y, w, h
;       dw stroke_witdth
;       db inner_color, border_color
;   3: Circle
;       dw x, y, radius
;       db color
;   4: Circle border
;       dw x, y, radius
;       dw stroke_witdth
;       db color
;   5: Circle with border
;       dw x, y, radius
;       dw stroke_witdth
;       db inner_color, border_color
;   6: Text
;       dw x, y, font_size, letter_spacing
;       db "String", 0
;       dw font_pointer
;       db color
;   7: Vector image
;       dw x, y, unit_size
;       dw image_pointer
;       db color
;   8: Empty item
;       dw x, y
;   9: Text input field
;       dw x, y, w, h
;       dw font_size, letter_spacing
;       db string_size
;       db "String", 0
;       dw font_pointer
;       db inner_color, text_color
;
;       db id, up_neighbor, right_neighbor, down_neighbor, left_neighbor
;       dw code_segment, select_event, enter_event


; TAILS
;   0: there are more elements
;   1: the following elements are children
;   2: last child
;  ff: last element

RenderGraphicDef:   ; esi: pointer to graphic definition
    push ebp
    mov ebp, esp
    push dword 0

    RenderGraphicDef_loop:
    add esi, 2
    mov edi, esi

    inc esi
    mov bx, [esi]
    add bx, [esp+2]
    mov [gRefTmpX], bx
    ror ebx, 16
    add esi, 2
    mov bx, [esi]
    add bx, [esp]
    mov [gRefTmpY], bx
    ror ebx, 16

    cmp byte[edi], 0
    je RenderGraphicDef_draw_0
    cmp byte[edi], 1
    je RenderGraphicDef_draw_1
    cmp byte[edi], 2
    je RenderGraphicDef_draw_2
    cmp byte[edi], 3
    je RenderGraphicDef_draw_3
    cmp byte[edi], 4
    je RenderGraphicDef_draw_4
    cmp byte[edi], 5
    je RenderGraphicDef_draw_5
    cmp byte[edi], 6
    je RenderGraphicDef_draw_6
    cmp byte[edi], 7
    je RenderGraphicDef_draw_7
    cmp byte[edi], 8
    je RenderGraphicDef_draw_8
    cmp byte[edi], 9
    je RenderGraphicDef_draw_9
    jmp RenderGraphicDef_exit

    ; Shapes
    RenderGraphicDef_draw_0:
        add esi, 2
        mov cx, [esi]
        ror ecx, 16
        add esi, 2
        mov cx, [esi]
        ror ecx, 16

        add esi, 2
        mov al, [esi]

        mov ah, 0x02
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_1:
        add esi, 2
        mov cx, [esi]
        ror ecx, 16
        add esi, 2
        mov cx, [esi]
        ror ecx, 16

        add esi, 2
        mov dx, [esi]

        add esi, 2
        mov al, [esi]

        mov ah, 0x03
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_2:
        add esi, 2
        mov cx, [esi]
        ror ecx, 16
        add esi, 2
        mov cx, [esi]
        ror ecx, 16

        add esi, 4
        mov al, [esi]

        push ebx
        push ecx
        mov ah, 0x02
        int 0xb0

        pop ecx
        pop ebx
        mov dx, [esi-2]
        inc esi
        mov al, [esi]

        mov ah, 0x03
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_3:
        add esi, 2
        mov cx, [esi]

        add esi, 2
        mov al, [esi]

        mov ah, 0x04
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_4:
        add esi, 2
        mov cx, [esi]

        add esi, 2
        mov dx, [esi]

        add esi, 2
        mov al, [esi]

        mov ah, 0x05
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_5:
        add esi, 2
        mov cx, [esi]

        add esi, 4
        mov al, [esi]

        push ebx
        push cx
        mov ah, 0x04
        int 0xb0

        pop cx
        pop ebx
        mov dx, [esi-2]
        inc esi
        mov al, [esi]
        
        mov ah, 0x05
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_6:
        add esi, 2
        mov cx, [esi]
        add esi, 2
        mov dx, [esi]
        add esi, 2

        push esi
        RenderGraphicDef_draw_6_loop:
            inc esi
            cmp byte[esi], 0
            jne RenderGraphicDef_draw_6_loop
        inc esi
        xor edi, edi
        mov di, [esi]

        add esi, 2
        mov al, [esi]
        pop esi
        
        mov ah, 0x08
        int 0xb0

        add esi, 4
        jmp RenderGraphicDef_next
        
    RenderGraphicDef_draw_7:
        add esi, 2
        mov cx, [esi]
        add esi, 4
        push esi
        mov al, [esi]
        sub esi, 2
        mov di, [esi]
        xor esi, esi
        mov si, di

        mov ah, 0x06
        int 0xb0

        pop esi
        inc esi
        jmp RenderGraphicDef_next

    RenderGraphicDef_draw_8:
        add esi, 2
        jmp RenderGraphicDef_next
    
    RenderGraphicDef_draw_9:
        add esi, 2
        mov cx, [esi]
        ror ecx, 16
        add esi, 2
        mov cx, [esi]
        ror ecx, 16

        add esi, 4
        mov al, [esi]

        push ebx
        push ecx
        mov ah, 0x02
        int 0xb0

        pop ecx
        pop ebx
        mov dx, [esi-2]
        inc esi
        mov al, [esi]

        mov ah, 0x03
        int 0xb0

        inc esi
        jmp RenderGraphicDef_next

    ; After drawing
    RenderGraphicDef_next:
    cmp byte[esi], 0
    je RenderGraphicDef_continue
    cmp byte[esi], 1
    je RenderGraphicDef_setUpChildren
    cmp byte[esi], 2
    je RenderGraphicDef_exitParent
    cmp byte[esi], 0xff
    je RenderGraphicDef_exit

    RenderGraphicDef_setUpChildren:
        inc esi
        push word[gRefTmpX]
        push word[gRefTmpY]
        jmp RenderGraphicDef_loop

    RenderGraphicDef_exitParent:
        inc esi
        pop edi
        jmp RenderGraphicDef_loop

    RenderGraphicDef_continue:
        inc esi
        jmp RenderGraphicDef_loop

    RenderGraphicDef_exit:
    mov esp, ebp
    pop ebp
    iret

    gRefTmpX dw 0
    gRefTmpY dw 0
    
;;; ------------------------0x0b---------------------------
GUILoop:
    ; Find selected element
    GUILoop_findLoop:
        add esi, 2

        cmp byte[esi], 9
        jge GUILoop_inputElement
            xor eax, eax
            mov ax, [esi-2]
            mov esi, eax
            cmp byte[esi-1], 0xff
            je GUILoop_exit
            jmp GUILoop_findLoop

        GUILoop_inputElement:
        cmp byte[esi], 9
        jne GUILoop_type_n9
            mov [gui_selected_ptr], si
            add esi, 13
            GUILoop_type_loop9:
                inc esi
                cmp byte[esi], 0
                jne GUILoop_type_loop9
            add esi, 5
            mov al, [edi]
            cmp byte[esi], al
            je GUILoop_keyboard

            add esi, 12
        GUILoop_type_n9:

        jmp GUILoop_findLoop
    


    ; Execute keyboard command
    GUILoop_keyboard:
    mov ebx, 0
    mov ecx, (100 << 16) | 100
    mov al, 0x28
    mov ah, 0x02
    int 0xb0

    mov ah, 0x01
    int 0x16

    cmp ax, 0x5000
    je GUILoop_moveDown
    cmp ax, 0x4800
    je GUILoop_moveUp
    cmp ax, 0x4d00
    je GUILoop_moveRight
    cmp ax, 0x4b00
    je GUILoop_moveLeft
    
    cmp ax, 0x1c0d
    je GUILoop_onEnter
    cmp al, 32
    jge GUILoop_onType
    jmp GUILoop_exit

    GUILoop_moveDown:
        jmp GUILoop_onSelect

    GUILoop_moveUp:
        jmp GUILoop_onSelect
        
    GUILoop_moveRight:
        jmp GUILoop_onSelect
        
    GUILoop_moveLeft:
        jmp GUILoop_onSelect
        

    GUILoop_onSelect:
        jmp GUILoop_exit

    GUILoop_onEnter:
        jmp GUILoop_exit

    GUILoop_onType:
        jmp GUILoop_exit


    GUILoop_exit:
    mov ah, 0x01
    int 0x16
    jz GUILoop_ret
    mov ah, 0x00
    int 0x16
    GUILoop_ret:
    iret

    gui_selected_ptr dw 0