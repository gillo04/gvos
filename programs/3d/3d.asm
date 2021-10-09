%define sWidth 320
%define sHeight 200

jmp _start

%include "utils.asm"
videoMode db 0
_start:
; mov ah, 0x0f
; int 0x10
; mov [videoMode], al

; call EnableGraphicMode
mov ah, 0x00
int 0xb0

EngineLoop:
    call ClearScreen
    ;;; Rotate the points

    ; increment rotZ
    fld dword[rotZ]
    fld dword[rotSpeed]
    faddp
    fstp dword[rotZ]

    ; increment rotX
    fld dword[rotX]
    fld dword[rotSpeed]
    faddp
    fstp dword[rotX]


    ; update RZ
    mov esi, RZ+2

    fld dword[rotZ]
    fcos
    fst dword[esi]
    add esi, 4*4
    fstp dword[esi]
    
    sub esi, 4
    fld dword[rotZ]
    fsin
    fst dword[esi]
    sub esi, 4*2
    fchs
    fstp dword[esi]

    ; update RX
    mov esi, RX+2+4*4

    fld dword[rotX]
    fcos
    fst dword[esi]
    add esi, 4*4
    fstp dword[esi]
    
    sub esi, 4
    fld dword[rotX]
    fsin
    fst dword[esi]
    sub esi, 4*2
    fchs
    fstp dword[esi]


    ; transform and project the first point
    mov eax, wireframe

    push eax
    mov esi, RZ
    mov edi, [eax]
    mov edx, tmp
    call FloatMatMult
    mov esi, tmp
    mov edi, tmp2
    call FloatMatCopy
    mov esi, RX
    mov edi, tmp2
    mov edx, tmp
    call FloatMatMult

    fld dword[distance]
    fld dword[tmp+2+2*4]
    faddp
    fstp dword[tmp+2+2*4]

    fld dword[tmp+2]
    fld dword[tmp+2+2*4]
    fdivp
    fld dword[focalLength]
    fmulp
    fistp dword[Ip0+2]

    fld dword[tmp+2+4]
    fld dword[tmp+2+2*4]
    fdivp
    fld dword[focalLength]
    fmulp
    fistp dword[Ip0+2+4]

    mov eax, [Ip0+2]
    add eax, sWidth/2
    mov [Ip0+2], eax
    mov eax, [Ip0+2+4]
    add eax, sHeight/2
    mov [Ip0+2+4], eax

    pop eax
    add eax, 4

    RenderingLoop:
        ; transform and project the point
        push eax
        mov esi, RZ
        mov edi, [eax]
        mov edx, tmp
        call FloatMatMult
        mov esi, tmp
        mov edi, tmp2
        call FloatMatCopy
        mov esi, RX
        mov edi, tmp2
        mov edx, tmp
        call FloatMatMult
        
        fld dword[distance]
        fld dword[tmp+2+2*4]
        faddp
        fstp dword[tmp+2+2*4]
        
        fld dword[tmp+2]
        fld dword[tmp+2+2*4]
        fdivp
        fld dword[focalLength]
        fmulp
        fistp dword[Ip1+2]

        fld dword[tmp+2+4]
        fld dword[tmp+2+2*4]
        fdivp
        fld dword[focalLength]
        fmulp
        fistp dword[Ip1+2+4]

        ; fld dword[tmp+2]
        ; fistp dword[Ip1+2]
        ; fld dword[tmp+2+4]
        ; fistp dword[Ip1+2+4]

        mov eax, [Ip1+2]
        add eax, sWidth/2
        mov [Ip1+2], eax
        mov eax, [Ip1+2+4]
        add eax, sHeight/2
        mov [Ip1+2+4], eax

        ; draw the line
        mov esi, Ip0
        mov edi, Ip1
        call DrawLine2P

        ; move Ip1 to Ip0
        mov esi, Ip1
        mov edi, Ip0
        call FloatMatCopy

        pop eax
        add eax, 4
        cmp dword[eax], 0
        jne RenderingLoop

    ;;; Time delay
    mov ah, 0x01
    int 0x16
    cmp al, 'x'
    je _exit
    mov cx, 0x05
    mov dx, 0x4240
    mov ah, 0x86
    int 0x15
    jmp EngineLoop

_exit:
mov ah, 0x00
int 0x16
mov ah, 0x01
int 0xb0

jmp JumpToKernel

jmp $

rotZ dd 0.0
rotX dd 0.0
rotSpeed dd 0.1

focalLength dd 200.0
distance dd 30.0

wireframe dd p0, p1, p2, p3, p0, p4, p5, p6, p7, p4, 0

; Points and matrices

RZ  db 3, 3
    dd 0.0, 0.0, 0.0
    dd 0.0, 0.0, 0.0
    dd 0.0, 0.0, 1.0

RX  db 3, 3
    dd 1.0, 0.0, 0.0
    dd 0.0, 0.0, 0.0
    dd 0.0, 0.0, 0.0

RY  db 3, 3
    dd 0.0, 0.0, 0.0
    dd 0.0, 0.0, 0.0
    dd 0.0, 0.0, 0.0

p0  db 1, 3
    dd 5.0
    dd 5.0
    dd 5.0

p1  db 1, 3
    dd -5.0
    dd 5.0
    dd 5.0

p2  db 1, 3
    dd -5.0
    dd -5.0
    dd 5.0

p3  db 1, 3
    dd 5.0
    dd -5.0
    dd 5.0

p4  db 1, 3
    dd 5.0
    dd 5.0
    dd -5.0

p5  db 1, 3
    dd -5.0
    dd 5.0
    dd -5.0

p6  db 1, 3
    dd -5.0
    dd -5.0
    dd -5.0

p7  db 1, 3
    dd 5.0
    dd -5.0
    dd -5.0

; Temporary points
tmp db 1, 3
    dd 0.0
    dd 0.0
    dd 0.0

tmp2 db 1, 3
    dd 0.0
    dd 0.0
    dd 0.0

Ip0 db 1,2
    dd 0
    dd 0

Ip1 db 1,2
    dd 0
    dd 0

nc dd 0
na dd 3.4
nb dd 3.6


%include "programs/3d/matrix_lib.asm"
%include "programs/3d/graphic_lib.asm"

times 512 * 3 - ($-$$) db 0