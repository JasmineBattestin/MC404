.text
.align 2

.globl middle_value_int
middle_value_int:
    srli a1, a1, 1  # a1 = n / 2
    slli a1, a1, 2  # para andar de 4 em 4 bytes
    add a0, a0, a1
    lw a0, 0(a0)
    ret

.globl middle_value_short
middle_value_short:
    srli a1, a1, 1  # a1 = n / 2
    slli a1, a1, 1  # para andar de 2 em 2 bytes
    add a0, a0, a1
    lh a0, 0(a0)
    ret

.globl middle_value_char
middle_value_char:
    srli a1, a1, 1  # a1 = n / 2
    add a0, a0, a1
    lb a0, 0(a0)
    ret

.globl value_matrix
value_matrix:
    li t0, 42
    mul t0, a1, t0  # t0 <- i * (qtde_colunas)
    add t0, t0, a2
    slli t0, t0, 2  # para andar de 4 em 4 bytes
    add a0, a0, t0
    lw a0, 0(a0)
    ret




