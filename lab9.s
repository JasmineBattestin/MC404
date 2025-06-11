.text
.align 2

read:
    li a7, 63 # syscall read (63)
    ecall
    ret


str_to_int:
    /*
    int str_to_int(char* str, int str_size)
    returns the int correspondent to the string
    */
    li t1, 0    # counter
    li t3, 10   # 10
    li t4, 0    # output

    lbu t6, 0(a0)
    li t5, '-'
    bne t5, t6, 1f
    addi a0, a0, 1
    addi t1, t1, 1  # counter won't need to consider the signal

    1:
        bge t1, a1, 1f

        mul t4, t4, t3  # 10 * t4

        lbu t2, 0(a0)   # pega um digito
        addi t2, t2, -0x30  # -'0'

        addi t1, t1, 1
        add t4, t4, t2
        addi a0, a0, 1

        j 1b

    1:
        bne t5, t6, fim
        li t5, -1
        mul t4, t4, t5

    fim:
        mv a0, t4
        ret


int_to_str:
    /*
    int int_to_str (int* str, int num, int size)
    returns buffer size
    */
    li t0, 0
    addi t1, a2, -1     # t1 <- size - 1

    bge a1, t0, 1f  # if (a1 >= 0)
    li t3, '-'
    sb t3, 0(a0)    # buffer starting with '-'
    addi t1, t1, 1       # size is one character bigger now
    li t2, -1
    mul a1, a1, t2  # now a1 stores abs(a1) - now we can make unsigned ops

    # a2: unsigned buffer size
    # t1: signed buffer size

    1:
        add a0, a0, t1     # goes to the last position in output buffer
        li t2, 10

    1:
        beq t0, a2, 1f
        remu t3, a1, t2     # t3 <- digito menos significativo
        divu a1, a1, t2     # a1 <- sem ultimo digito
        addi t3, t3, 0x30
        sb t3, 0(a0)

        addi a0, a0, -1
        addi t0, t0, 1
        j 1b
    1:
        mv a0, t1
        ret


number_size:
    /*
    int number_size (int number)
    return the number of digits of a number
    */

    # size of the output (we know it's up to 4 digits)
    4:
        # 4 digitos
        li t0, 1000
        li t2, 4
        div t1, a0, t0
        bnez t1, 1f

    3:
        # 3 digitos
        li t0, 100
        li t2, 3
        div t1, a0, t0
        bnez t1, 1f

    2:
        # 2 digitos
        li t0, 10
        li t2, 2
        div t1, a0, t0
        bnez t1, 1f
        
        # 1 digito
        li t2, 1

    1:
        # t2 armazena numero de digitos

    mv a0, t2
    ret


linked_list_search:
    /*
        int linked_list_search (int* head_node)
        returns the index of the node from the search (or -1)
    */

    li t4, 0    # counter

    # while a0 != 0
    1: 
        beqz a0, 1f

        lw t1, 0(a0)
        lw t2, 4(a0)
        lw t3, 8(a0)

        add t1, t1, t2      # t1 <- t1 + t2
        beq t1, s1, 2f      # if(soma == int input)

        addi t4, t4, 1

        mv a0, t3
        j 1b

    1:
        # nao encontrou
        li t4, -1

    2:
        mv a0, t4
        ret


write:
    /*
    void write (int fd, int* output_address)
    */

    li a2, 5          # number of bytes to write
    li a7, 64           # syscall write (64)
    ecall
    ret



.globl _start
_start:


li a0, 0  # file descriptor = 0 (stdin)
la a1, input_address #  buffer to write the data
li a2, 6  # size (reads [up to] 6 bytes)

jal read

mv s0, a0   # saving number of bytes read
addi s0, s0, -1     # removing '\n'

la a0, input_address
mv a1, s0
jal str_to_int

mv s1, a0   # saving input in int format

la a0, head_node
jal linked_list_search
mv s2, a0   # saving output number (int)

# output (int) is in a0; we must put in inside a buffer (char*)
jal number_size
mv s3, a0   # saving output number size (number of digits)

# calling: int_to_str (int* str, int num, int size)
la a0, output_address
mv a1, t4
mv a2, s3
jal int_to_str
    
mv s4, a0   # saving output buffer size

la a1, output_address
add a1, a1, s4

li t2, '\n'
sb t2, 1(a1)

li a0, 1    # file descriptor = 1 (stdout)
la a1, output_address
jal write


exit:
    li a0, 0           # return code\n
    li a7, 93           # syscall exit (93) \n
    ecall


.bss
.align 2
input_address: .skip 8
output_address: .skip 8