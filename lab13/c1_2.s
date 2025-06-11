.text
.align 2

.globl my_function
my_function:
    /*
    int my_function(int a, int b, int c){
    int aux = b - mystery_function(a+b, a) + c;
    return c - mystery_function(aux, b) + aux;
    };
    */
    # a -> a0
    # b -> a1
    # c -> a2
    add t0, a0, a1  # SUM 1 -> t0

    # saves registers (because we'll call a function)
    addi sp, sp, -16     # aloca espaco na pilha
    sw ra, 12(sp)   # empilha RA
    sw a2, 8(sp)    # empilha c
    sw a1, 4(sp)    # empilha b
    sw a0, 0(sp)    # empilha a

    mv a1, a0   # a1 <- a
    mv a0, t0   # a0 <- SUM 1
    jal mystery_function    # CALL 1: mystery_function (a + b, a)

    mv t0, a0   # t0 <- return of previous function call (CALL 1)

    # recover values from stack
    lw ra, 12(sp)   
    lw a2, 8(sp)    
    lw a1, 4(sp)   
    lw a0, 0(sp)    
    addi sp, sp, 16 # desempilha

    sub t0, a1, t0  # t0 <- DIFF 1 := b - retorno
    
    add t0, t0, a2  # t0 <- SUM 2 := c + DIFF1

    addi sp, sp, -32     # aloca espaco na pilha
    sw ra, 16(sp)   # empilha RA
    sw a2, 12(sp)    # empilha c
    sw a1, 8(sp)    # empilha b
    sw a0, 4(sp)    # empilha a
    sw t0, 0(sp)    # empilha SUM 2

    mv a0, t0   # a0 <- SUM 2
    jal mystery_function    # CALL 2

    mv t1, a0   # t1 <- return of CALL 2

    # recover values from stack
    lw ra, 16(sp)   
    lw a2, 12(sp)    
    lw a1, 8(sp)   
    lw a0, 4(sp)
    lw t0, 0(sp)    
    addi sp, sp, 32 # desempilha

    sub t1, a2, t1  # t1 <- DIFF 2
    add a0, t0, t1  # a0 <- SUM 3 := DIFF 2 + SUM 2

    ret     # returns SUM 3
    