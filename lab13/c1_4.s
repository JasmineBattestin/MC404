.text
.align 2

.globl operation
operation:
    # parameters a-h stored in registers a0-a7
    
    # additional parameters i-n stored (backwards) in stack
    # backwards: first parameters in later (higher) addresses   

    lw t2, 8(sp)    # k
    lw t4, 16(sp)    # m

    add a0, a1, a2  # b + c
    sub a0, a0, a5  # b + c - f
    add a0, a0, a7  # b + c - f + h
    add a0, a0, t2  # b + c - f + h + k
    sub a0, a0, t4  # b + c - f + h + k - m
    
    ret