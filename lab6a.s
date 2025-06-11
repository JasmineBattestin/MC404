.text   # same as .section .text

.globl _start
_start:

# read syscall
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data

    li a2, 20  # size (reads 20 bytes)
    li a7, 63 # syscall read (63)
    ecall

    li s11, 20
    li t5, 0
    

# start

loop:

    # pega os digitos de y

    if1:
        li t6, 0
        bne t5, t6, if2
        lbu t0, 0(a1)
        lbu t1, 1(a1)
        lbu t2, 2(a1)
        lbu t3, 3(a1)
        j 1f
    if2: 
        li t6, 5
        bne t5, t6, if3
        lbu t0, 5(a1)
        lbu t1, 6(a1)
        lbu t2, 7(a1)
        lbu t3, 8(a1)
        j 1f
    if3:
        li t6, 10
        bne t5, t6, if4
        lbu t0, 10(a1)
        lbu t1, 11(a1)
        lbu t2, 12(a1)
        lbu t3, 13(a1)
        j 1f
    if4:
        lbu t0, 15(a1)
        lbu t1, 16(a1)
        lbu t2, 17(a1)
        lbu t3, 18(a1)
        j 1f

    1:
    # removing '0': get the actually int value
    addi t0, t0, -0x30
    addi t1, t1, -0x30
    addi t2, t2, -0x30
    addi t3, t3, -0x30

    # obtem o valor de y
    # valor posicional decimal
    li s0, 10       # 10 em s0
    mul t2, t2, s0
    li s0, 100  # 100 em s0
    mul t1, t1, s0
    li s0, 1000  # 1000 em s0
    mul t0, t0, s0

    add t2, t2, t3
    add t1, t1, t2
    add t0, t0, t1

    # y esta em t0
    mv t1, t0

    # contador de iteracoes: vamos fazer 10
    li s1, 0
    li s2, 10;  # quantidade de iteracoes

    srli t1, t1, 1  # initial guess k = y / 2 em t1

    loop2:
        divu t2, t0, t1   # y / k em t2
        add t2, t2, t1      # (y / k) + k em t2
        srli t2, t2, 1      # ((y / k) + k) / 2 em t2
        mv t1, t2           # k' em t1

        addi s1, s1, 1      # s1++
        bne s1, s2, loop2    # continue if s1 != 10

    # output stored in t1
    # less significative: mod 1000
    # 1000 stored in s0
    
    packing:
        li s0, 1000
        la a3, output_address
        add a3, a3, t5

        divu t4, t1, s0
        addi t4, t4, 0x30
        sb t4, 0(a3)
        remu t1, t1, s0

        li s0, 100     # s0 vale 100
        divu t4, t1, s0
        addi t4, t4, 0x30
        sb t4, 1(a3)
        remu t1, t1, s0

        li s0, 10     # s0 vale 10
        divu t4, t1, s0
        addi t4, t4, 0x30
        sb t4, 2(a3)
        remu t1, t1, s0

        addi t4, t1, 0x30
        sb t4, 3(a3)

        li t4, ' '
        sb t4, 4(a3)

        addi t5, t5, 5
        bne t5, s11, loop    # continue if t5 != 20


    li t4, '\n'
    la a3, output_address
    sb t4, 19(a3)

    # agora t1 eh zero
    # write syscall
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_address
    li a2, 20          # number of bytes to write
    li a7, 64           # syscall write (64)
    ecall



# exit
    li a0, 0           # return code\n
    li a7, 93           # syscall exit (93) \n
    ecall


.bss    # non initialized variables
input_address: .skip 0x20  # buffer
output_address: .skip 0x20

.rodata     # constants

.data   # initialized variables
