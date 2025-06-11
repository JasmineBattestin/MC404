.text
.align 2

open:
    /*
    int open (char* file_path)
    returns file descriptor (fd)
    */

    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall
    ret

setCanvasSize:
    /*
    void setCanvasSize(int width, int height)
    */
    li a7, 2201
    ecall
    ret

close:
    /*
    void close(int fd)
    */
    li a7, 57            # syscall close
    ecall
    ret

read:
    /*
    void read(int fd, int* input_address, int size)
    */
    li a7, 63 # syscall read (63)
    ecall
    ret


copia:
    /*
    int copia(int* input_address, int* output_address)
    returns number of characters until whitespaces
    */

    li t0, 0x30     # we're considering ascii values up to 0x30 are whitespaces
    li t2, 0    # counter: number of characters

    1:
        lbu t1, 0(a0)
        blt t1, t0, 1f

        sb t1, 0(a1)

        addi a0, a0, 1
        addi a1, a1, 1
        addi t2, t2, 1

        j 1b
        
    1:
        mv a0, t2
        ret


str_to_int:
    /*
    int str_to_int(char* str, int str_size)
    returns the int correspondent to the string
    */
    li t1, 0    # counter
    li t3, 10   # 10
    li t4, 0    # output

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
        mv a0, t4
        ret


printImage:
    /*
    void printImage(int* image, int width, int height)
    */

    # assumes we're in the image's first pixel

    # t0: row (y) (i)
    # t1: column (x) (j)
    # a0: image (address)
    # a1: width
    # a2: height

    addi s5, a2, -1     # height - 1
    addi s6, a1, -1     # width - 1

    # first lets print the borders
    # horizontal borders
    # for(int i = 0; i <= height - 1; i += height - 1){ for (j = 0; j <= width - 1; j ++) }

    li t0, 0

    3:
        bge t0, a2, 3f
        li t1, 0

        4:
            bge t1, a1, 4f

            # salvar a0, a1, a2
            mv s11, a0
            mv s10, a1
            mv s9, a2

            # a0:pixel's x coordinate
            # a1: pixel's y coordinate
            # a2: concatenated pixel's colors: R|G|B|A
            mv a0, t1
            mv a1, t0
            li a2, 0x000000FF   # black
            li a7, 2200 # syscall setPixel (2200)
            ecall

            # recuperar valores
            mv a0, s11
            mv a1, s10
            mv a2, s9

            add t1, t1, 1
            j 4b

        4:
        add t0, t0, s5
        j 3b
    3:


    # vertical borders
    # for(int j = 0; j <= width - 1; j += width - 1){ for (i = 0; i <= width - 1; i ++) }

    li t1, 0

    5:
        bge t1, a1, 5f
        li t0, 0

        6:
            
            bge t0, a2, 6f

            # a0:pixel's x coordinate
            # a1: pixel's y coordinate
            # a2: concatenated pixel's colors: R|G|B|A
            mv a0, t1
            mv a1, t0
            li a2, 0x000000FF   # black
            li a7, 2200 # syscall setPixel (2200)
            ecall

            # recuperar valores
            mv a0, s11
            mv a1, s10
            mv a2, s9

            add t0, t0, 1
            j 6b

        6:
        add t1, t1, s6
        j 5b
    5:


    # rest of image
    # for (int i = 1; i < height - 1; i++){ for(int j = 1; j < width - 1; j++) }
    li t0, 1
    
    1:
        bge t0, s5, 1f

        li t1, 1

        2:
            bge t1, s6, 2f

            mul t2, t0, a1      # em t2: k = i * width
            add t2, t2, t1      # em t2: k = i * width + j

            add t2, t2, a0      # a partir do começo da imagem (posição do pixel)

            # lbu t3, 0(t2)       # em t3: intensidade do pixel na posicao i,j
            li t3, 0

            #############

            # FILTER

            # from row i to row i +- 1: k +- width
            # from column j to column j +- 1: k +- 1
 
            # [i - 1] [j + 1]
            sub t4, t2, a1    # t4 <- t2 - width
            addi t4, t4, 1      # t4 <- t4 + 1
            lbu t5, 0(t4)
            sub t3, t3, t5
            
            # [i - 1] [j]
            sub t4, t2, a1    # t4 <- t2 - width
            lbu t5, 0(t4)
            sub t3, t3, t5

            # [i - 1] [j - 1]
            sub t4, t2, a1    # t4 <- t2 - width
            addi t4, t4, -1      # t4 <- t4 - 1
            lbu t5, 0(t4)
            sub t3, t3, t5

            # [i] [j + 1]
            lbu t4, 1(t2)
            sub t3, t3, t4

            # [i] [j]
            li t5, 8
            lbu t4, 0(t2)
            mul t4, t4, t5      # t4 <- 8 * t4
            add t3, t3, t4      # t3 <- t3 - t4

            # [i] [j - 1]
            lbu t4, -1(t2)
            sub t3, t3, t4

            # [i + 1] [j + 1]
            add t4, t2, a1    # t4 <- t2 + width
            addi t4, t4, 1      # t4 <- t4 + 1
            lbu t5, 0(t4)
            sub t3, t3, t5

            # [i + 1] [j]
            add t4, t2, a1    # t4 <- t2 + width
            lbu t5, 0(t4)
            sub t3, t3, t5

            # [i + 1] [j - 1]
            add t4, t2, a1    # t4 <- t2 + width
            addi t4, t4, -1      # t4 <- t4 - 1
            lbu t5, 0(t4)
            sub t3, t3, t5


            li t4, 0
            bge t3, t4, non_negative
            li t3, 0
            j processed_number

            non_negative:
            li t4, 256
            bltu t3, t4, processed_number
            li t3, 255

            processed_number:

            # END OF FILTER
            #############

            slli t2, t3, 8

            add t2, t2, t3
            slli t2, t2, 8

            add t2, t2, t3
            slli t2, t2, 8

            addi t2, t2, 255    # alpha

            # a0:pixel's x coordinate
            # a1: pixel's y coordinate
            # a2: concatenated pixel's colors: R|G|B|A
            mv a0, t1
            mv a1, t0
            mv a2, t2
            li a7, 2200 # syscall setPixel (2200)
            ecall

            # recuperar valores
            mv a0, s11
            mv a1, s10
            mv a2, s9

            addi t1, t1, 1
            j 2b

        2:

        addi t0, t0, 1
        j 1b

    1:
    ret


.globl _start
_start:

    la a0, input_file
    jal open

    mv s0, a0   # saves file descriptor


    mv a0, s0
    la a1, input_address
    li a2, 262159
    jal read

    # width number of digits
    la a0, input_address + 3    # skips "P5 "
    la a1, no_whitespaces_w
    jal copia
    mv s1, a0   # saves width number of digits

    # width
    la a0, no_whitespaces_w
    mv a1, s1
    jal str_to_int
    mv s2, a0   # saves width value


    # height number of digits
    la a0, input_address + 3
    add a0, a0, s1
    addi a0, a0, 1  # starting in the first height digit

    la a1, no_whitespaces_h
    jal copia
    mv s3, a0   # saves height number of digits

    # height
    la a0, no_whitespaces_h
    mv a1, s3
    jal str_to_int
    mv s4, a0   # saves height value


    
    mv a0, s2
    mv a1, s4
    jal setCanvasSize

    # image starts at 9 + s1 + s3 in the input buffer
    la a0, input_address + 9
    add a0, a0, s1
    add a0, a0, s3
    mv a1, s2
    mv a2, s4
    jal printImage


    li a0, 0           # return code
    jal exit


exit:
    li a0, 0           # return code\n
    li a7, 93           # syscall exit (93) \n
    ecall

.bss
.align 2
input_address: .skip 262159     # buffer
no_whitespaces_w: .skip 0x5
no_whitespaces_h: .skip 0x5

.rodata
.align 2
input_file: .asciz "image.pgm"