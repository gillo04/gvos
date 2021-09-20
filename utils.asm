%include "constants.asm"

fontStr db "font", 0

JumpToKernel:
    mov bx, KERNEL_SEGMENT
    mov ds, bx
    jmp KERNEL_SEGMENT:KERNEL_ADDR