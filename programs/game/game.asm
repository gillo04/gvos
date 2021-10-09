jmp _start

%include "utils.asm"
%include "programs/game/map.asm"
title db "GAME DEMO", 0

playerX db 0
playerY db 0

_start:
; Load the font at 0x800
mov esi, fontStr
mov ah, 0x02
int 0xa2

mov bx, PROGRAM_SEGMENT
mov es, bx
mov bx, 0x800

mov dl, 0

mov ah, 0x00
int 0xa2        ; LoadSectors

; Enter graphic mode
mov ah, 0x00
int 0xb0

; Draw fixed elements
mov ebx, (20 << 16) | 110
mov esi, title
mov edi, 0x800
mov al, 0x37
mov cx, 2
mov dx, 11
mov ah, 0x08
int 0xb0

mov ebx, (SCREEN_HEIGHT/2-50 << 16) | SCREEN_WIDTH/2-50
mov ecx, (100 << 16) | 100
mov dx, 5
mov al, 0x0f
mov ah, 0x03
int 0xb0

mov esi, map
GameLoop:
    call DrawScreen

    mov ah, 0x00
    int 0x16
    cmp al, 's'
    je MoveDown
    cmp al, 'w'
    je MoveUp
    cmp al, 'a'
    je MoveLeft
    cmp al, 'd'
    je MoveRight
    cmp al, 'x'
    je _exit
    jmp GameLoop_continue

    MoveDown:
        cmp byte[playerY], 9
        je GameLoop_continue
        mov al, [playerX]
        mov bl, [playerY]
        inc bl
        call GetMapValueAt
        cmp al, 1
        je GameLoop_continue
        inc byte[playerY]
        jmp GameLoop_continue

    MoveUp:
        cmp byte[playerY], 0
        je GameLoop_continue
        mov al, [playerX]
        mov bl, [playerY]
        dec bl
        call GetMapValueAt
        cmp al, 1
        je GameLoop_continue
        dec byte[playerY]
        jmp GameLoop_continue
        
    MoveRight:
        cmp byte[playerX], 9
        je GameLoop_continue
        mov al, [playerX]
        inc al
        mov bl, [playerY]
        call GetMapValueAt
        cmp al, 1
        je GameLoop_continue
        inc byte[playerX]
        jmp GameLoop_continue

    MoveLeft:
        cmp byte[playerX], 0
        je GameLoop_continue
        mov al, [playerX]
        dec al
        mov bl, [playerY]
        call GetMapValueAt
        cmp al, 1
        je GameLoop_continue
        dec byte[playerX]
        jmp GameLoop_continue

    GameLoop_continue:

    ; Delay
    mov cx, 0x05
    mov dx, 0x4240
    mov ah, 0x86
    int 0x15

    jmp GameLoop


DrawScreen:
    ; Clear screen
    mov ebx, (SCREEN_HEIGHT/2-50 << 16) | SCREEN_WIDTH/2-50
    mov ecx, (100 << 16) | 100
    mov al, 0x00
    mov ah, 0x02
    int 0xb0

    ; Draw player
    xor ax, ax
    mov al, [playerX]
    mov cl, 10
    mul cl
    add ax, SCREEN_WIDTH/2-50
    mov bx, ax

    xor ax, ax
    mov al, [playerY]
    mov cl, 10
    mul cl
    add ax, SCREEN_HEIGHT/2-50
    ror ebx, 16
    mov bx, ax
    ror ebx, 16

    mov ecx, (10 << 16) | 10
    mov al, 0x28
    mov ah, 0x02
    int 0xb0


    ; Draw map
    mov dx, 0
    mov ebx, (SCREEN_HEIGHT/2-50 << 16) | SCREEN_WIDTH/2-50
    mov esi, map
    DrawMap:
        cmp byte[esi], 1
        je DrawMap_block
        jmp DrawMap_next

        DrawMap_block:
            push dx
            push ebx

            mov ecx, (10 << 16) | 10
            mov al, 0x18
            mov ah, 0x02
            int 0xb0

            pop ebx
            pop dx

        DrawMap_next:
        inc esi
        inc dx
        add bx, 10
        cmp dx, 10
        jl DrawMap_noAdvanceCol
            mov dx, 0
            sub bx, 100
            ror ebx, 16
            add bx, 10
            ror ebx, 16
        DrawMap_noAdvanceCol:

        cmp byte[esi], 0xff
        jne DrawMap

    ret

GetMapValueAt:  ; [al: x, bl: y] (al: value)
    mov bh, 0
    mov ah, 0
    push ax
    xor eax, eax
    mov ax, bx
    mov cx, 10
    mul cx
    pop bx
    add ax, bx
    add eax, map

    mov al, [eax]

    ret

_exit:
mov ah, 0x01
int 0xb0
jmp JumpToKernel


times 512*2 - ($ - $$) db 0