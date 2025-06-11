.text
.align 2

.globl increment_my_var
increment_my_var:
    # void increment_my_var()
    # increments 1 to global variable
    la a0, my_var
    lw a1, 0(a0)
    addi a1, a1, 1
    sw a1, 0(a0)
    ret


.data
.align 2
.globl my_var   # global variable named my_var
my_var: .word 10    # type int (word, 4 bytes) and initial value 10