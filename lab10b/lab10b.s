.text
.align 2

str_size:
    /* int str_size (char* str) */

    li t2, 0    # counter

    1:
        lbu t1, 0(a0)
        beqz t1, 1f
        addi t2, t2, 1
        addi a0, a0, 1
        j 1b

    1:
        mv a0, t2

    ret


invert_str:
    /*
    void (char* str, int size)
    returns string inverted
    */

    1:

    add t0, a0, a1  # t0 <- end of string address
    mv t5, t0   # (pointer of end of str coppied to t5)
    addi t0, t0, -1 # t0 <- last string digit (conversion from 1-index to 0-index)
    

    srli t1, a1, 1  # t1 <- a1 / 2 (half size)
    addi t1, t1, 1  # that's needed to use the bge operator
    
    li t4, 0    # counter

    # skip signal
    li t6, '-'
    lbu t2, 0(a0)
    bne t2, t6, 1f
    addi a0, a0, 1

    1:
        addi t4, t4, 1  # counter += 1 (conditions are 1-index)
        bgeu t4, t1, 1f # if t4 > half size then stop
        lbu t2, 0(a0)   # gets digit
        
        mv t3, t2       # aux <- digit
        lbu t2, 0(t0)   # gets simmetric-opposite digit
        sb t2, 0(a0)    # 0(a0) <- 0(t0)
        sb t3, 0(t0)    # 0(t0) <- 0(a0) inicial

        addi a0, a0, 1  # next position (pointer l)
        addi t0, t0, -1 # next position (pointer r)
        j 1b

    1:
        lbu t6, 0(t5)
        beqz t6, 1f
        sb zero, 0(t5)

    1:

        ret


# search here
.globl recursive_tree_search
recursive_tree_search:
    /*
    Definition (in C):
    int recursive_tree_search(Node *root_node, int val){
        if(LEFT != 0){
            int value = recursive_tree_search(left, val);
            if(value != 0)  return value + 1;
        }
        if(RIGHT != 0){
            int value = recursive_tree_search(right, val);
            if(value != 0)  return value + 1;
        }
        # leaf node OR father node with no succesful children
        if(VAL == val)  return 1;
        return 0;
    }
    */
    
    # store a0, a1, ra on stack
    addi sp, sp, -0x20    # sp always 16-byte aligned
    sw ra, 20(sp)    # save ra
    sw a0, 16(sp)    # save a0
    sw a1, 12(sp)    # save a1

    lw t1, 0(a0)    # VAL
    lw t2, 4(a0)    # LEFT
    lw t3, 8(a0)    # RIGHT

    # store val, left, right on stack
    sw t1, 8(sp)
    sw t2, 4(sp)
    sw t3, 0(sp)

    # a1 will be the same for all function calls (because is the value we're searching for)

    1:  # LEFT != 0
        beqz t2, 1f

        mv a0, t2

        jal recursive_tree_search   # recursive_tree_search(LEFT, val);
        mv t0, a0   # t0 <- int value = recursive_tree_search(LEFT, val);

        # recover parameters of the routine currently in execution
        lw ra, 20(sp)    # recover ra
        lw a0, 16(sp)    # recover a0
        lw a1, 12(sp)    # recover a1
        lw t1, 8(sp)    # recover val
        lw t2, 4(sp)    # recover left
        lw t3, 0(sp)    # recover right

        # if(value != 0)  return value + 1;
        beqz t0, 1f
        addi sp, sp, 0x20     # unstack
        addi t0, t0, 1      # return + 1
        mv a0, t0
        ret

    1:  # RIGHT != 0
        beqz t3, 1f

        mv a0, t3

        jal recursive_tree_search   # recursive_tree_search(RIGHT, val);
        mv t0, a0   # t0 <- int value = recursive_tree_search(RIGHT, val);

        # recover parameters of the routine currently in execution
        lw ra, 20(sp)    # recover ra
        lw a0, 16(sp)    # recover a0
        lw a1, 12(sp)    # recover a1
        lw t1, 8(sp)    # recover val
        lw t2, 4(sp)    # recover left
        lw t3, 0(sp)    # recover right

        # if(value != 0)  return value + 1;
        beqz t0, 1f
        addi sp, sp, 0x20     # unstack
        addi t0, t0, 1      # return + 1
        mv a0, t0
        ret


    # leaf node OR father node with no succesful children 
    1:
        # if(VAL == val)  return counter;
        bne t1, a1, 1f
        addi sp, sp, 0x20     # unstack
        li a0, 1            # return 1;
        ret

    1:
        addi sp, sp, 0x20     # unstack
        li a0, 0            # return 0;
        ret


.globl puts
puts:

    /*
    Definition (in C):
    void puts ( const char* str )

    Description:
    Writes the string pointed by str to stdout and appends a newline character ('\n').

    Parameters: string terminated by \0	

    Specifics:
        - The function begins copying from the address specified (str) until it reaches 
        the terminating null character ('\0').
        - This terminating null-character is not copied to the stream.
    */

    # ABI ilp32 determina usar pilha para armazenar variavel quando 
    # a rotina faz uso do endereco da variavel local

    addi sp, sp, -8     # aloca espaco
    sw a0, 4(sp)        # empilha string address
    
    sw ra, 0(sp)    # empilha RA
    jal str_size
    lw ra, 0(sp)    # recupera RA
    addi sp, sp, 4  # desempilha RA

    mv a2, a0   # a2 <- string size (number of bytes to write)
    lw a0, 0(sp)    # recupera string address

    mv a1, a0           # string address in a1
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall

    lw a0, 0(sp)    # recupera string address
    addi sp, sp, 4  # desempilha a0

    li t1, '\n'
    addi sp, sp, -4
    sb t1, 0(sp)    # empilha '\n'
    mv a1, sp   # a1 <- endereco de '\n'

    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 1          # number of bytes to write (1)
    li a7, 64           # syscall write (64)
    ecall

    addi sp, sp, 4  # desempilha

    ret
    

.globl gets
gets:
    /*

    Definition (in C):
    char* gets ( char* str )

    Description:
    Reads characters from the stdin and stores them as a string into str until a newline character is reached.

    Parameters: buffer to be filled

    Return: 
        - on success: str
        - read error: error indicator is set; null pointer. str content may have changed.

    Specifics:
        - source: stdin
        - newline character is not copied into str (if found)
        - null character appended after the characters copied to str

    */

    addi sp, sp, -4
    sw a0, 0(sp)

    mv a1, a0 #  buffer to write the data
    lbu t1, 0(a1)
    li t2, '\n'
    
    1:
        li a0, 0  # file descriptor = 0 (stdin)
        li a2, 1  # size
        li a7, 63 # syscall read (63)
        ecall

        lbu t1, 0(a1)
        beq t1, t2, 1f

        addi a1, a1, 1
        j 1b

    1:
        sb zero, 0(a1)
        lw a0, 0(sp)
        addi sp, sp, 4
    
    ret

.globl atoi
atoi:
    /*
    
    Definition (in C):
    int atoi (const char *str)

    Description:
    Parses the string str interpreting its content as an integral number, which is returned as a value of type int.

    Parameters: string terminated by \0	

    Return: integer represented by the string

    Specifics:
        - The function first discards as many whitespace characters (as in isspace) as necessary until the first 
        non-whitespace character is found.
        - Then, starting from this character, takes an optional initial plus or minus sign followed by as many 
        base-10 digits as possible, and interprets them as a numerical value.
        - The string can contain additional characters after those that form the integral number, which are ignored 
        and have no effect on the behavior of this function.
        - If the first sequence of non-whitespace characters in str is not a valid integral number, 
        or if no such sequence exists because either str is empty or it contains only whitespace characters, 
        no conversion is performed and zero is returned.

    */

    addi sp, sp, -4     # aloca espaco na pilha
    sw a0, 0(sp)        # empilha string address

    mv t0, a0

    li t4, 0    # quantidade de whitespaces no comeco

    1:  # discard whitespace characters until first non-whitespace character
        lbu t1, 0(t0)

        whitespace_cases:
            li t2, ' '      # space
            beq t1, t2, repeat

            li t2, '\t'     # horizontal tab
            beq t1, t2, repeat

            li t2, '\n'     # newline
            beq t1, t2, repeat

            li t2, 0x0b     # '\v' (vertical tab)
            beq t1, t2, repeat

            li t2, 0x0c     # '\f' (feed)
            beq t1, t2, repeat

            li t2, 0x0d     # '\r' (carriage return)
            beq t1, t2, repeat

        # non-whitespace character
        j 1f

        repeat:
            addi t0, t0, 1
            addi t4, t4, 1
            j 1b

    1:
        mv a2, t4   # saving number of whitespaces

        # takes optional plus or minus sign

        2:
            li t2, '-'
            li t3, 0    # indicativo de negativo: 0 (não), 1 (sim)
            bne t1, t2, 2f
            li t3, 1
            addi t0, t0, 1  # to get the number we must skip the sign
            lbu t1, 0(t0)

        2:
            li t2, '+'
            bne t1, t2, 2f
            addi t0, t0, 1  # to get the number we must skip the sign
            lbu t1, 0(t0)


        # if there's not valid integral number after it, return zero
        # base-10 numbers are ascii characters between 0x30 and 0x39

        2:
            li t2, 0x30
            bgeu t1, t2, 2f
            j invalid

        2:
            li t2, 0x40
            bgeu t1, t2, invalid
    

    # interprets base-10 digits as a numerical value

    addi sp, sp, -8     # aloca espaco
    sw ra, 4(sp)    # empilha RA
    sw t0, 0(sp)    # empilha t0
    jal str_size
    lw t0, 0(sp)    # recupera t0
    addi sp, sp, 4  # desempilha t0
    lw ra, 0(sp)    # recupera RA
    addi sp, sp, 4  # desempilha RA

    mv t1, a0   # t1 <- string size
    lw a0, 0(sp)    # recupera string address

    addi sp, sp, 4  # desempilha string address

    li t4, 0    # counter
    li t6, 0    # output

    sub t2, t1, a2  # t2 <- t1 - a2   (size - whitespaces)

    1:
        lbu t1, 0(t0)   # pega um digito

        # ignore additional characters
        li t5, 0x40
        bgeu t1, t5, 1f     # chegou-se a caracter invalido
        li t5, 0x30
        bltu t1, t5, 1f     # chegou-se a caracter invalido

        bgeu t4, t2, 1f     # chegou ao fim da string: ultimo caracter antes do \0

        li t5, 10   # 10
        mul t6, t6, t5  # 10 * t6
   
        addi t1, t1, -0x30  # -'0' : transforma digito em seu valor numerico

        add t6, t6, t1  # somando digito considerando notacao posicional
        addi t4, t4, 1  # +1 no contador
        addi t0, t0, 1  # indo para o proximo digito

        j 1b

    1:
        # multiplicar por -1 se negativo
        beqz t3, 1f
        li t5, -1
        mul t6, t6, t5  # t6 <- -t6

    1:
        mv a0, t6
        ret

    invalid:
        mv a0, zero
        ret


.globl itoa
itoa:
    /*

    Definition (in C):
        char* itoa ( int value, char *str, int base )

    Description:
    Converts an integer value to a null-terminated string using the specified base (10 or 16) 
    and stores the result in the array given by str parameter.

    Parameters:
        value: value to be converted to a string
        str: array in memory where to store the resulting null-terminated string
        base: numerical base used to represend the value as a string. can be any base until 36.
            uses signed representation

    Return: a pointer to the resulting null-terminated string, same as parameter str.

    Specifics:
        If base is 10 and value is negative, the resulting string is preceded with a minus sign (-).
        With base 16, value is considered unsigned.

    Considering: 
        - Only bases 10 and 16 will be tested.
        - The tests won't be case-sensitive.

    */

    # saves parameters

    # check if number is negative to add minus sign

    li t6, 0        # negative indicator
    bge a0, zero, 1f  # if (value >= 0)
    li t6, 1
    li t2, '-'
    sb t2, 0(a1)    # buffer starting with '-'
    addi a1, a1, 1  # one additional character due to signal
    
    li t2, -1
    mul a0, a0, t2  # now a0 stores abs(a0) - now we can make unsigned ops


    1:

        mv t0, a0   # t0 <- value
        mv t1, a1   # t1 <- str address
        li t4, 0    # counter (str size)

    1:  # get digits and store in str, according to the base

        la t3, digits       # t3 <- address of the buffer with equivalent digits
        remu t5, t0, a2     # t5 <- remainder of (current value) / base
        add t3, t3, t5      # position of the t0-th digit of buffer of digits
        lbu t5, 0(t3)       # t5 <- equivalent ascii digit
        sb t5, 0(t1)        # str <- ascii digit

        addi t1, t1, 1      # goes to next position in buffer to write the digits
        divu t0, t0, a2     # current value becomes quocient
        addi t4, t4, 1      # counter += 1

        beqz t0, 1f         # if quocient is zero, stop (after appending the remainder)
        j 1b


    1:
        beqz t6, 1f
        addi a1, a1, -1
        addi t4, t4, 1  # size is 1 unit bigger due to signal

    1:

        # note we added the digits backwards
        # we must invert the string

        # save parameters and RA (because we'll call a function)
        addi sp, sp, -8     # aloca espaco
        sw ra, 4(sp)   # empilha RA
        sw a1, 0(sp)    # empilha a1 (str address)

        mv a0, a1   # passing str address as parameter a0
        mv a1, t4   # passing str size as parameter a1
        jal invert_str

        lw a1, 0(sp)    # recupera a1 (str address)
        lw ra, 4(sp)    # recupera RA
        addi sp, sp, 8  # desempilha

        mv a0, a1   # string address as return
        ret


.globl exit
exit:

    /*
    Definition (in C):
    void exit(int code)
    
    Description:
    Calls exit syscall to finish execution.

    Parameters: return code (usually used as error code)
    */

    # return code already stored in a0, passed as argument
    li a7, 93
    ecall
    ret


.rodata
.align 2
digits: .string "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"