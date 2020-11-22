LoadSectors: ; set ES:BX to where you want to read the sector, set CH to the cylinder and CL to the starting sector, set AL to how many sectors you want to write
    push ebp
    mov ebp, esp

    xor dx, dx  ; dh = head 0, dl = drive 0
    LoadSectors_readDisk:
            mov ah, 0x02
            int 0x13

            jc LoadSectors_readDisk    ; if there's an error, int 13 will return a carry. retry

    mov esp, ebp
    pop ebp
    ret

JumpToProgram:
    mov ax, 0x9000
    mov bx, 0
    mov es, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    jmp 0x9000:0x0

JumpToKernel:
    mov ax, 0x2000
    mov bx, 0
    mov es, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    jmp 0x2000:0x0