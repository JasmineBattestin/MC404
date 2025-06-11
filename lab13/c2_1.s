.text
.align 2

.globl swap_int
swap_int:
    lw t0, 0(a0)
    lw t1, 0(a1)

    mv t2, t0
    sw t1, 0(a0)
    sw t2, 0(a1)
    
    li a0, 0
    ret

.globl swap_short
swap_short:
    lh t0, 0(a0)
    lh t1, 0(a1)

    mv t2, t0
    sh t1, 0(a0)
    sh t2, 0(a1)
    
    li a0, 0
    ret

.globl swap_char
swap_char:
    lb t0, 0(a0)
    lb t1, 0(a1)

    mv t2, t0
    sb t1, 0(a0)
    sb t2, 0(a1)
    
    li a0, 0
    ret



