.text
.align 2

.globl node_creation
node_creation:

    addi sp, sp, -8
    li t0, 30
    sw t0, (sp)
    li t0, 25
    sb t0, 4(sp)
    li t0, 64
    sb t0, 5(sp)
    li t0, -12
    sh t0, 6(sp)
    mv a0, sp

    addi sp, sp, -4
    sw ra, (sp)


    
    jal mystery_function

    lw ra, (sp)
    addi sp, sp, 4

    addi sp, sp, 8
    

    ret