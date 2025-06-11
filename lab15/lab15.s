.text

.set READ_coord, 0xFFFF0100
.set X_coord, 0xFFFF0110
.set Y_coord, 0xFFFF0114
.set Z_coord, 0xFFFF0118
.set WHEEL_dir, 0xFFFF0120
.set ENGINE_dir, 0xFFFF0121
.set BRAKES, 0xFFFF0122

.align 4


syscall_set_engine_and_steering:
/*
    Code: 10

    Description:
    Start the engine to move the car.
    a0's value can be -1 (go backward), 0 (off) or 1 (go forward).
    a1's value can range from -127 to +127, where negative values 
    turn the steering wheel to the left and positive values to the right.

    Parameters:
        a0: movement direction
        a1: steering wheel angle

    Return: 0 if successful and -1 if failed
*/

    li t1, WHEEL_dir
    sb a1, 0(t1)

    li t0, ENGINE_dir
    sb a0, 0(t0)

    ret


syscall_set_hand_brake:
/*
    Code: 11

    Description: a0 must be 1 to use hand brakes.

    Parameters:
        a0: value stating if the hand brakes must be used
*/

    li t0, BRAKES
    lb a0, 0(t0)

    ret



syscall_get_position:
/*
    Code: 15

    Description: Read the car's approximate position using the GPS device.

    Parameters:
        a0: address of the variable that will store the value of x position.
        a1: address of the variable that will store the value of y position.
        a2: address of the variable that will store the value of z position.
*/

    li t0, READ_coord
    li t1, 1
    sb t1, 0(t0)    # triggers GPS to start reading coordinates

    1:  # check if reading is completed
        lb t1, 0(t0)
        bnez t1, 1b

    li t0, X_coord
    li t1, Y_coord
    li t2, Z_coord

    lw t0, 0(t0)
    lw t1, 0(t1)
    lw t2, 0(t2)

    sw t0, 0(a0)
    sw t1, 0(a1)
    sw t2, 0(a2)

    ret

.globl int_handler
int_handler:
    ###### Syscall and Interrupts handler ######

    # Salvar o restante do contexto

    csrrw sp, mscratch, sp  # troca sp com mscratch
    addi sp, sp, -16   #    # aloca espaço na pilha da ISR

    sw t0, 0(sp)   
    sw t1, 4(sp)    

    # Tratar a exceção

    # You mustn't call the exit syscall (as there isn't an operating system, it doesn't exist).
    # The syscall operation code must be passed via register a7, as done in previous exercises.

    li t0, 10
    beq a7, t0, 1f
    li t0, 11
    beq a7, t0, 2f
    li t0, 15
    beq a7, t0, 3f
    j 4f

    1:
        jal syscall_set_engine_and_steering
        j 4f

    2:
        jal syscall_set_hand_brake
        j 4f

    3:
        jal syscall_get_position

    4:
    
    # Recuperar o contexto
    lw t0, 0(sp)   
    lw t1, 4(sp)    

    addi sp, sp, 16
    csrrw sp, mscratch, sp
    
    # <= Implement your syscall handler here

    csrr t0, mepc  # load return address (address of the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
    csrw mepc, t0  # stores the return address back on mepc
    mret           # Recover remaining context (pc <- mepc)

 
.globl _start
_start:
    # initializes the user's stack
    la sp, user_stack_base
    
    # 1: registrar a ISR (direct mode)
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.
    # mtvec <- endereço do int_handler

    # 2: configurar o reg. mscratch para apontar para a pilha da isr
    la t0, isr_stack_base   # t0 <- base da pilha
    csrw mscratch, t0   # mscratch <- t0

    # 3: configurar os periféricos (nao tem)

    # Change to user mode
    csrr t1, mstatus
    li t2, ~0x1800      # bits 11 and 12 (mstatus.MPP field)
    and t1, t1, t2      # update with value 00 (U-mode)
    csrw mstatus, t1    

    # Call the function user_main (defined in another file)
    la t0, user_main # Loads the user software
    csrw mepc, t0 # entry point into mepc
    mret # PC <= MEPC; mode <= MPP;


.globl control_logic
control_logic:
    # implement your control logic here, using only the defined syscalls
    
    # ligar motor
    li a0, 1
    li a1, 0
    li a7, 10
    ecall

    1:
        la a0, x_coordinate
        la a1, y_coordinate
        la a2, z_coordinate
        li a7, 15
        ecall

        la t0, z_coordinate
        lw t0, 0(t0)
        li t1, -90
        blt t0, t1, 1b

    li a0, 1
    li a1, -20
    li a7, 10
    ecall

    1:
        la a0, x_coordinate
        la a1, y_coordinate
        la a2, z_coordinate
        li a7, 15
        ecall

        la t0, x_coordinate
        lw t0, 0(t0)
        li t1, 120
        bge t0, t1, 1b

    li a0, 0
    li a1, 0
    li a7, 10
    ecall

    1:
        la a0, x_coordinate
        la a1, y_coordinate
        la a2, z_coordinate
        li a7, 15
        ecall

        la t0, x_coordinate
        lw t0, 0(t0)
        li t1, 90
        bge t0, t1, 1b

        li a0, 1
        li a7, 11
        ecall

        ret


.bss
.align 4
x_coordinate: .skip 4
y_coordinate: .skip 4
z_coordinate: .skip 4

# To allocate the stacks, you can declare two arrays in your program.
# pilha cheia descendente (full-descending stack)
isr_stack: .skip 1024   # Final da pilha das ISRs
isr_stack_base:  # Base da pilha das ISRs

user_stack: .skip 1024
user_stack_base:
