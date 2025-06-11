.text
.align 2

.globl operation
operation:
    # parameters a-h stored in registers a0-a7
    
    # additional parameters i-n stored (backwards) in stack
    # backwards: first parameters in later (higher) addresses   

    lw t0, 0(sp)    # i
    lw t1, 4(sp)    # j
    lw t2, 8(sp)    # k
    lw t3, 12(sp)    # l
    lw t4, 16(sp)    # m
    lw t5, 20(sp)    # n

    addi sp, sp, -16
    sw ra, (sp)

    addi sp, sp, -32
    sw a5, 0(sp)    # f
    sw a4, 4(sp)    # e
    sw a3, 8(sp)    # d
    sw a2, 12(sp)    # c
    sw a1, 16(sp)    # b
    sw a0, 20(sp)    # a
    
    mv a0, t5
    mv a1, t4
    mv a2, t3
    mv a3, t2
    mv a4, t1
    mv a5, t0

    mv t6, a6   # aux = g
    mv a6, a7   # a6 = h
    mv a7, t6   # a7 = g

    jal mystery_function
    addi sp, sp, 32

    lw ra, (sp)
    addi sp, sp, 16
    
    ret