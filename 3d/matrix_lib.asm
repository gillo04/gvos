; --- Integer matrix representation in memory --- ;
;  + the number of columns and rwos are represented with one byte each
;  + each index is a byte long
;  -> columns, rows, i0, i1, i2, ...

; --- Float matrix representation in memory --- ;
;  + the number of columns and rwos are represented with one byte each
;  + each index is a double word long (4 bytes)
;  -> columns, rows, i0, i1, i2, ...

;;;
;;; Matrix operations
;;;

IntMatMult: ; ESI: pointer to the first matrix, EDI: pointer to the second matrix, EDX: pointer to the output matrix
    mov bh, [edi]
    mov [edx], bh
    mov [i_cols_b], bh
    inc edx
    mov bl, [esi]
    mov [i_cols_a], bl

    mov bl, [esi+1]
    mov [edx], bl
    mov [i_rows_a], bl
    mov bl, [edi+1]
    mov [i_rows_b], bl

    add esi, 2
    add edi, 2
    inc edx
    
    mov al, [i_rows_a]
    MatMult_rowLoop:
        push ax
        mov ch, [i_cols_b]
        MatMult_columnLoop: ; loops over every cell in an output row
            push edx
            xor cl, cl
            mov dl, [i_cols_a]

            MatMult_columnLoop_calc:    ; calculates the value of a single output cell
                push dx

                mov al, [esi]
                mov bl, [edi]
                mul bl

                add cl, al

                inc esi
                xor eax, eax
                mov al, [i_cols_b]
                add edi, eax
                pop dx
                dec dl
                cmp dl, 0
                jne MatMult_columnLoop_calc

            pop edx
            mov [edx], cl
            inc edx
            xor eax, eax
            mov al, [i_cols_a]
            sub esi, eax

            mov al, [i_cols_b]
            mov bl, [i_rows_b]
            mul bl
            sub edi, eax
            inc edi

            dec ch
            cmp ch, 0
            jne MatMult_columnLoop
        
        xor eax, eax
        mov al, [i_cols_a]
        add esi, eax 
        mov al, [i_cols_b]
        sub edi, eax

        pop ax
        dec al
        cmp al, 0
        jne MatMult_rowLoop

    ret
    i_cols_a db 0
    i_rows_a db 0
    i_cols_b db 0
    i_rows_b db 0

FloatMatCopy: ; ESI: starting matrix, EDI: destination
    mov al, [esi]
    mov bl, [esi+1]
    mul bl
    mov cl, al
    
    mov ax, [esi]
    mov [edi], ax

    add esi, 2
    add edi, 2

    FloatMatCopy_loop:
        mov eax, [esi]
        mov [edi], eax

        add esi, 4
        add edi, 4
        dec cl
        cmp cl, 0
        jg FloatMatCopy_loop
    
    ret


FloatMatMult: ; ESI: pointer to the first matrix, EDI: pointer to the second matrix, EDX: pointer to the output matrix
    mov bh, [edi]
    mov [edx], bh
    mov [f_cols_b], bh
    inc edx
    mov bl, [esi]
    mov [f_cols_a], bl

    mov bl, [esi+1]
    mov [edx], bl
    mov [f_rows_a], bl
    mov bl, [edi+1]
    mov [f_rows_b], bl

    add esi, 2
    add edi, 2
    inc edx
    
    mov al, [f_rows_a]
    FloatMatMult_rowLoop:
        push ax
        mov ch, [f_cols_b]
        FloatMatMult_columnLoop: ; loops over every cell in an output row
            push edx
            mov dl, [f_cols_a]

            fldz
            FloatMatMult_columnLoop_calc:    ; calculates the value of a single output cell
                fld dword[esi]
                fld dword[edi]
                fmulp
                faddp

                add esi, 4
                xor eax, eax
                mov al, [f_cols_b]
                mov bl, 4
                mul bl
                add edi, eax
                
                dec dl
                cmp dl, 0
                jne FloatMatMult_columnLoop_calc

            pop edx
            fstp dword[edx]
            add edx, 4
            xor eax, eax
            mov al, [f_cols_a]
            mov bl, 4
            mul bl
            sub esi, eax

            mov al, [f_cols_b]
            mov bl, [f_rows_b]
            mul bl
            mov bl, 4
            mul bl
            sub edi, eax
            add edi, 4

            dec ch
            cmp ch, 0
            jne FloatMatMult_columnLoop
        
        xor eax, eax
        mov al, [f_cols_a]
        mov bl, 4
        mul bl
        add esi, eax 
        mov al, [f_cols_b]
        mul bl
        sub edi, eax

        pop ax
        dec al
        cmp al, 0
        jne FloatMatMult_rowLoop

    ret
    f_cols_a db 0
    f_rows_a db 0
    f_cols_b db 0
    f_rows_b db 0

;;;
;;; Standard math operations
;;;

MathAbs: ; AX: number
    cmp ax, 0
    jg MathAbs_exit

    not ax
    inc ax

    MathAbs_exit:
    ret