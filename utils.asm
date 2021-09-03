%include "constants.asm"

JumpToKernel:
    mov bx, KERNEL_SEGMENT
    mov ds, bx
    jmp KERNEL_SEGMENT:KERNEL_ADDR