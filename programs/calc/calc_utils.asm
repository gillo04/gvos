IsNumber:   ; ESI: pointer to null-terminated string, AL: result (0 = not a number, 1 = is a number)
    cmp byte[esi], '0'
    jl IsNumber_fail
    cmp byte[esi], '9'
    jg IsNumber_fail
    inc esi
    cmp byte[esi], 0
    jne IsNumber
    mov al, 1
    ret

    IsNumber_fail:
    mov al, 0
    ret