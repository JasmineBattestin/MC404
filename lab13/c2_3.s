.text
.align 2

.globl fill_array_int
fill_array_int:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi sp, sp, -400   # array_int allocated in stack
    mv a0, sp
    li t0, 0
    li t1, 100

    1:
        bge t0, t1, 1f
        sw t0, 0(a0)
        addi a0, a0, 4  # 4 em 4 bytes
        addi t0, t0, 1  
        j 1b

    1:
        mv a0, sp
        
        jal mystery_function_int
        
        addi sp, sp, 400
        lw ra, 0(sp)
        addi sp, sp, 4

    ret


.globl fill_array_short
fill_array_short:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi sp, sp, -200   # array_short allocated in stack
    mv a0, sp
    li t0, 0
    li t1, 100

    1:
        bge t0, t1, 1f
        sh t0, 0(a0)
        addi a0, a0, 2  #
        addi t0, t0, 1  
        j 1b

    1:
        mv a0, sp
        
        jal mystery_function_short

        addi sp, sp, 200    #
        lw ra, 0(sp)
        addi sp, sp, 4

    ret

.globl fill_array_char
fill_array_char:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi sp, sp, -100   # array_char allocated in stack
    mv a0, sp
    li t0, 0
    li t1, 100

    1:
        bge t0, t1, 1f
        sb t0, 0(a0)
        addi a0, a0, 1  #
        addi t0, t0, 1  
        j 1b

    1:
        mv a0, sp
        
        jal mystery_function_char

        addi sp, sp, 100    #
        lw ra, 0(sp)
        addi sp, sp, 4

    ret






