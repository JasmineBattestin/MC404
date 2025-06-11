.text

.set GPT_base, 0xFFFF0100
.set MIDI_base, 0xFFFF0300
.align 2
    

.globl main_isr
main_isr:
    # 1 salva contexto
    
    csrrw sp, mscratch, sp  # troca sp com mscratch
    addi sp, sp, -16   #    # aloca espaço na pilha da ISR

    sw t0, 0(sp)   
    sw t1, 4(sp)    
    sw t2, 8(sp)    

    # 2 trata a interrupção externa

    # General Purpose Timer
    # generate interrupts every 100 ms

    li t0, GPT_base
    addi t0, t0, 0x8
    li t1, 100
    sw t1, 0(t0)

    # GPT interrupt handler must increment a global time counter (_system_time)
    la t1, _system_time
    lw t2, 0(t1)
    addi t2, t2, 100
    sw t2, 0(t1)

    # 3 recupera contexto
    lw t0, 0(sp)   
    lw t1, 4(sp)    
    lw t2, 8(sp) 

    addi sp, sp, 16
    csrrw sp, mscratch, sp
    mret



.globl _start
_start:
    # initializes the program's stack
    la sp, program_stack_base
    
    # 1: registrar a ISR (direct mode)
    la t0, main_isr
    csrw mtvec, t0  # mtvec <- endereço da main_isr

    # 2: configurar o reg. mscratch para apontar para a pilha da isr
    la t0, isr_stack_base   # t0 <- base da pilha
    csrw mscratch, t0   # mscratch <- t0

    # 3: configurar os periféricos
    # configuração realizada através da escrita em registradores do periférico
    li t0, GPT_base
    addi t0, t0, 0x8
    li t1, 100
    sw t1, 0(t0)

    # 4: habilitar as interrupções

    # habilita interrupcoes externas
    csrr t1, mie    # seta o bit 11 (MEIE) do r mie
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t1

    # habilita interrupcoes global
    csrr t1, mstatus    # seta o bit 3 (MIE) do r mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    # calls the main function
    # call using jal instruction (no need of mret) because it won't be necessary to change execution mode
    jal main


.globl play_note
play_note:
    /*
    void play_note(int ch, int inst, int note, int vel, int dur);

    access the MIDI Synthesizer peripheral through MMIO

    parameters:
        ch: channel;
        inst: instrument ID;
        note: musical note;
        vel: note velocity;
        dur: note duration.
    */

    li t0, MIDI_base
    sb a0, 0(t0)
    sh a1, 2(t0)
    sb a2, 4(t0)
    sb a3, 5(t0)
    sh a4, 6(t0)

    ret


.data
.align 4
# _system_time needs to be initialized as zero
.globl _system_time
_system_time: .word 0


.bss
.align 4
# To allocate the stacks, you can declare two arrays in your program.
# pilha cheia descendente (full-descending stack)
isr_stack: .skip 1024   # Final da pilha das ISRs
isr_stack_base:  # Base da pilha das ISRs

program_stack: .skip 1024
program_stack_base:
