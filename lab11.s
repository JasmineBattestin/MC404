.text
.set READ_coord, 0xFFFF0100
.set X_coord, 0xFFFF0110
.set Y_coord, 0xFFFF0114
.set Z_coord, 0xFFFF0118
.set WHEEL_dir, 0xFFFF0120
.set ENGINE_dir, 0xFFFF0121
.set BRAKES, 0xFFFF0122

.align 2

# control a car to move it from a parking lot to the entrance of the Test Track in, at most, 180 seconds
# use MMIO to control the steering wheel, engine, brakes and get coordinates.

# The entrance to the Test Track is placed at: x: 73, y: 1, z: -19
# vira voltante a partir do z valendo -35

# get coordinates
/*
base+0x10	X-axis
base+0x14   Y-axis
base+0x18   Z-axis
*/

/*
Read coordinates and rotation of the car (while)

Last car position: {x: 180, y: 2.5, z: -108}

*/

# steering wheel - volante
/*
base+0x20: sets the steering wheel direction.
    Negative values indicate steering to the left,
    Positive values indicate steering to the right.

The steering wheel direction values range from -127 to 127, negative values steer to the left and positive values to the right.
*/


# engine - motor
/*
base+0x21: sets the engine direction
    1: forward
    0: off
    -1: backward
*/
 

# brakes - freio
/*
base+0x22: sets the hand break. (1 = enabled)
*/





.globl _start
_start:
    li t0, ENGINE_dir
    li t1, 1
    sb t1, 0(t0)

    1:

        li t0, READ_coord
        li t1, 1
        sb t1, 0(t0)    # triggers GPS to start reading coordinates

    2:  # check if reading is completed

        lb t1, 0(t0)
        bnez t1, 2b

    2:  # reading completed: check if z > 
        li t0, ENGINE_dir
        lb t2, 0(t0)

        beqz t2, 3f

        li t1, 0     # engine on -> off

        3: 
            li t1, 1     # engine off -> on

        sb t1, 0(t0)

        li t0, Z_coord
        lw t0, 0(t0)
        li t1, -90
        blt t0, t1, 1b

    1:
        li t0, WHEEL_dir
        li t1, -20
        sb t1, 0(t0)

    1:

        li t0, READ_coord
        li t1, 1
        sb t1, 0(t0)    # triggers GPS to start reading coordinates

    2:  # check if reading is completed

        lb t1, 0(t0)
        bnez t1, 2b

        li t0, X_coord
        lb t2, 0(t0)
        li t1, 120
        bge t2, t1, 1b

        li t0, ENGINE_dir
        sb zero, 0(t0)

        li t0, WHEEL_dir
        sb zero, 0(t0)

    2:
        li t0, READ_coord
        li t1, 1
        sb t1, 0(t0)    # triggers GPS to start reading coordinates

    1:
        lb t1, 0(t0)
        bnez t1, 1b

        li t0, X_coord
        lb t2, 0(t0)
        li t1, 90
        bge t2, t1, 2b

        li t0, BRAKES
        li t1, 1
        lb t1, 0(t0)


    li a0, 0
    jal exit


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




.bss
.align 2
input_address: .skip 8
output_address: .skip 8

.rodata