.text   # same as .section .text


putin_register:

    lbu t0, 0(a1)
    lbu t1, 1(a1)
    lbu t2, 2(a1)
    lbu t3, 3(a1)
    lbu t4, 4(a1)

    ret


get_number:
    # removing '0': get the actually int value
    addi t1, t1, -0x30
    addi t2, t2, -0x30
    addi t3, t3, -0x30
    addi t4, t4, -0x30

    # valor posicional decimal
    li s0, 10       # 10 em s0
    mul t3, t3, s0
    li s0, 100  # 100 em s0
    mul t2, t2, s0
    li s0, 1000  # 1000 em s0
    mul t1, t1, s0

    add t3, t3, t4
    add t2, t2, t3
    add t1, t1, t2

    li t2, '-'
    bne t2, t0, end

    # t0 == '-'
    li t2, -1
    mul t1, t1, t2

    end:
        mv a0, t1
        ret



square_root:
    # contador de iteracoes: vamos fazer 21
    li s8, 0
    li s9, 21;  # quantidade de iteracoes
    mv s10, t1

    srai t1, t1, 1  # initial guess k = y / 2 em t1

    loop:
        div t2, s10, t1     # y / k em t2
        add t2, t2, t1      # (y / k) + k em t2
        srai t2, t2, 1      # ((y / k) + k) / 2 em t2
        mv t1, t2           # k' em t1

        addi s8, s8, 1      # s8++
        bltu s8, s9, loop    # continue if s8 < 21

    # output stored in t1
    mv a0, t1
    ret
    


.globl _start
_start:

/*
    PERMANENT REGISTERS     
    s1: x
    s2: dc² - y²
    s3: dc
    s4: x_c
    s5: -x
    s6: abs(x)
    s7: y
    s8-s10: used inside functions
    s11: T_R
*/


# read syscall
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data

    li a2, 32  # size (reads 32 bytes)
    li a7, 63 # syscall read (63)
    ecall    

# start

    # t0 a t4 realizam operacoes

    # y_b
    jal putin_register
    jal get_number
    mv t5, a0
    mv s1, a0
    mul t5, t5, t5  # y_b squared


    # d_a
    # T_R
    la a1, input_address
    addi a1, a1, 26
    jal putin_register
    jal get_number
    mv t6, a0
    mv s11, a0


    # T_A
    la a1, input_address
    addi a1, a1, 11
    jal putin_register
    jal get_number

    sub t6, t6, a0  # d_a = T_R - T_A

    # conversao e resto da operacao: multiplicar d_a por 0,3
    li s4, 3
    mul t6, t6, s4
    li s4, 10
    divu t6, t6, s4

    mul t6, t6, t6  # d_a squared
    mv s2, t6

    # y_b² + d_a²
    add t5, t5, t6

    # d_b
    # T_R
    mv t6, s11

    # T_B
    la a1, input_address
    addi a1, a1, 16
    jal putin_register
    jal get_number

    sub t6, t6, a0  # T_R - T_B
    
    # conversao e resto da operacao: multiplicar d_b por 0,3
    li s4, 3
    mul t6, t6, s4
    li s4, 10
    divu t6, t6, s4
    mul t6, t6, t6  # d_b squared

    # y_b² + d_a² - d_b²
    sub t5, t5, t6

    srai t5, t5, 1     # (y_b² + d_a² - d_b²) / 2
    div t5, t5, s1     # (y_b² + d_a² - d_b²) / (2 y_b)
    mv s7, t5
    # y em s7

    mul t5, t5, t5      # y² em t5
    # remember d_a² is in s2
    sub t6, s2, t5  # da² - y²

    mv t1, t6
    jal square_root
    mv s6, a0   # modulo de x em s6

    # d_c
    # T_R
    mv s3, s11

    # T_C
    la a1, input_address
    addi a1, a1, 21
    jal putin_register
    jal get_number
    sub s3, s3, a0  # T_R - T_C

    # conversao e resto da operacao: multiplicar d_c por 0,3
    li s4, 3
    mul s3, s3, s4
    li s4, 10
    divu s3, s3, s4
    # d_c em s3


    mul s2, s3, s3  # d_c squared
    # d_c² em s2

    sub s2, s2, t5  # d_c² - y² em s2

    # considering: d_c² - y² = (x - x_c)²
    # x_c
    la a1, input_address
    addi a1, a1, 6  
    jal putin_register
    jal get_number
    mv t1, a0   
    mv s4, a0   # x_c em s4

    # first try: x is positive
    sub t1, s6, t1  
    mul t1, t1, t1  # (x - x_c)² em t1

    bge t1, s2, x_bigger
    sub t2, s2, t1
    j final

    x_bigger:
        sub t2, t1, s2 # (x - x_c)² - [d_c² - y²]

    final:

    # second try: x is negative
    li t3, -1
    mul t3, t3, s6  # -x em t3
    mv s5, t3   # -x em s5
    sub t1, t3, s4  
    mul t1, t1, t1  # (-x - x_c)² em t1

    bge t1, s2, x_bigger_2
    sub t3, s2, t1
    j final_2

    x_bigger_2:
        sub t3, t1, s2 # (x - x_c)² - [d_c² - y²]

    final_2:

    # vamos usar o que gerar menor diferenca em modulo
    blt t2, t3, x_positive
    mv s1, s5
    j packing

    x_positive:
        mv s1, s6

    # x signed value is in s1
    # y signed value is in s7

    packing:
    # packing output
    
    la a3, output_address

    li t0, 0

    bge s1, t0, x_sinal_pos
    li t1, '-'
    sb t1, 0(a3)
    
    j valor_x

    x_sinal_pos:
        li t1, '+'
        sb t1, 0(a3)

    valor_x:

        mv s1, s6   # agora que ja colocamos o sinal trabalharemos com abs(x)
        # abs x em s1

        li s0, 1000

        divu t4, s1, s0
        addi t4, t4, 0x30
        sb t4, 1(a3)
        remu s1, s1, s0

        li s0, 100     # s0 vale 100
        divu t4, s1, s0
        addi t4, t4, 0x30
        sb t4, 2(a3)
        remu s1, s1, s0

        li s0, 10     # s0 vale 10
        divu t4, s1, s0
        addi t4, t4, 0x30
        sb t4, 3(a3)
        remu s1, s1, s0

        addi t4, s1, 0x30
        sb t4, 4(a3)

    li t4, ' '
    sb t4, 5(a3)

    li t0, 0

    bge s7, t0, y_sinal_pos
    li t1, '-'
    sb t1, 6(a3)
    li t1, -1
    mul s7, s7, t1  # pegando abs(y)
    j valor_y

    y_sinal_pos:
        li t1, '+'
        sb t1, 6(a3)

    # modulo de y em s7
    valor_y:
        li s0, 1000

        divu t4, s7, s0
        addi t4, t4, 0x30
        sb t4, 7(a3)
        remu s7, s7, s0

        li s0, 100     # s0 vale 100
        divu t4, s7, s0
        addi t4, t4, 0x30
        sb t4, 8(a3)
        remu s7, s7, s0

        li s0, 10     # s0 vale 10
        divu t4, s7, s0
        addi t4, t4, 0x30
        sb t4, 9(a3)
        remu s7, s7, s0

        addi t4, s7, 0x30
        sb t4, 10(a3)

    li t1, '\n'
    sb t1, 11(a3)

    write_part:

    # write syscall
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_address
    li a2, 12          # number of bytes to write
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
