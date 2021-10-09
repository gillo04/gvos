; Screen size: 320 X 200

; EnableGraphicMode:
;     mov ah, 0x00
;     mov al, 0x13
;     int 0x10
;     ret

ClearScreen:
    mov dx, 0
    mov ah, 0x0c
    mov al, 0x00
    ClearScreen_hLoop:
        mov cx, 0
        mov bl, 0
        ClearScreen_wLoop:
            int 0x10

            inc cx
            cmp cx, 320
            jl ClearScreen_wLoop
        sub cx, 320
        inc dx
        cmp dx, 200
        jl ClearScreen_hLoop

    ret

DrawLine: ; AX: x0, BX: y0, CX: x1, DX: y1
    push ax
    push cx
    mov [line_x1], cx
    mov [line_y1], dx

    ; Calculate dx and sx
    sub cx, ax
    mov ax, cx
    call MathAbs
    mov [line_dx], ax

    pop cx
    pop ax

    mov word [line_sx], 1
    cmp ax, cx
    jl DrawLine_sx
    mov word [line_sx], -1
    DrawLine_sx:

    ; Calculate dy and sy
    push ax
    
    sub dx, bx
    mov ax, dx
    call MathAbs
    not ax
    inc ax
    mov [line_dy], ax

    pop ax

    mov word [line_sy], 1
    cmp bx, dx
    jl DrawLine_sy
    mov word [line_sy], -1
    DrawLine_sy:

    mov cx, ax
    mov dx, bx

    mov ax, [line_dx]
    mov bx, [line_dy]
    add ax, bx


    ; At this point:
    ; AX: err
    ; CX: x0
    ; DX: y0

    DrawLine_loop:
        push ax
        push bx

        ; Draw pixel
        mov ah, 0x0c
        mov al, 0x0f
        mov bl, 0
        int 0x10

        pop bx
        pop ax
        ; Exit condition
        cmp cx, [line_x1]
        jne DrawLine_continue
        cmp dx, [line_y1]
        je DrawLine_exit
        DrawLine_continue:

        mov bx, ax
        add bx, bx  ; BX: e2

        cmp bx, [line_dy]
        jl DrawLine_xAdvance
        add ax, [line_dy]
        add cx, [line_sx]
        DrawLine_xAdvance:

        cmp bx, [line_dx]
        jg DrawLine_yAdvance
        add ax, [line_dx]
        add dx, [line_sy]
        DrawLine_yAdvance:

        jmp DrawLine_loop
    DrawLine_exit:

    ret
    line_x1 dw 0
    line_y1 dw 0

    line_dx dw 0
    line_dy dw 0
    line_sx dw 0
    line_sy dw 0

DrawLine2P: ; ESI: point 1, EDI: point 2;
    add esi, 2
    add edi, 2

    mov ax, [esi]
    mov bx, [esi+4]
    
    mov cx, [edi]
    mov dx, [edi+4]

    cmp bx, dx
    jg DrawLine2P_switch
    push ax
    push bx
    mov ax, cx
    mov bx, dx
    pop dx
    pop cx
    DrawLine2P_switch:

    call DrawLine

    ret