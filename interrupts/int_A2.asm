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
        add bx, 14
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
        mov dh, [es:bx+1]
        mov cl, [es:bx+2]
        mov al, [es:bx+3]

        jmp GetFileInfo_exit

    GetFileInfo_notFound:
        mov al, 0

    GetFileInfo_exit:
    iret