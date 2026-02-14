/***************************************************************************
 * Copyright (c) 2025 10xEngineers
 *
 * This program and the accompanying materials are made available under the
 * terms of the MIT License which is available at
 * https://opensource.org/licenses/MIT.
 *
 * SPDX-License-Identifier: MIT
 **************************************************************************/


/**************************************************************************/
/**************************************************************************/
/**                                                                       */
/** ThreadX Component                                                     */
/**                                                                       */
/**   Thread                                                              */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


    .section .text
/**************************************************************************/
/*                                                                        */
/*  FUNCTION                                               RELEASE        */
/*                                                                        */
/*    _tx_thread_stack_build                             RISC-V32/GNU     */
/*                                                           6.4.x        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    Akif Ejaz, 10xEngineers                                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function builds a stack frame on the supplied thread's stack.  */
/*    The stack frame results in a fake interrupt return to the supplied  */
/*    function pointer.                                                   */
/*                                                                        */
/*  INPUT                                                                 */
/*                                                                        */
/*    thread_ptr                            Pointer to thread control blk */
/*    function_ptr                          Pointer to return function    */
/*                                                                        */
/*  OUTPUT                                                                */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  CALLS                                                                 */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  CALLED BY                                                             */
/*                                                                        */
/*    _tx_thread_create                     Create thread service         */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  23-12-2025        Akif Ejaz            Initial Version 6.4.x          */
/*                                                                        */
/**************************************************************************/
/* VOID   _tx_thread_stack_build(TX_THREAD *thread_ptr, VOID (*function_ptr)(VOID))
{  */
    .global  _tx_thread_stack_build
_tx_thread_stack_build:

    /* Build a fake interrupt frame.  The form of the fake interrupt stack
       on the RISC-V should look like the following after it is built:
                    Reg     Index
       Stack Top:   1        0      Interrupt stack frame type
                    x27      1      Initial s11
                    x26      2      Initial s10
                    x25      3      Initial s9
                    x24      4      Initial s8
                    x23      5      Initial s7
                    x22      6      Initial s6
                    x21      7      Initial s5
                    x20      8      Initial s4
                    x19      9      Initial s3
                    x18     10      Initial s2
                    x9      11      Initial s1
                    x8      12      Initial s0
                    x31     13      Initial t6
                    x30     14      Initial t5
                    x29     15      Initial t4
                    x28     16      Initial t3
                    x7      17      Initial t2
                    x6      18      Initial t1
                    x5      19      Initial t0
                    x17     20      Initial a7
                    x16     21      Initial a6
                    x15     22      Initial a5
                    x14     23      Initial a4
                    x13     24      Initial a3
                    x12     25      Initial a2
                    x11     26      Initial a1
                    x10     27      Initial a0
                    x1      28      Initial ra
                    --      29      reserved
                    mepc    30      Initial mepc
If floating point support:
                    f0      31      Inital ft0
                    f1      32      Inital ft1
                    f2      33      Inital ft2
                    f3      34      Inital ft3
                    f4      35      Inital ft4
                    f5      36      Inital ft5
                    f6      37      Inital ft6
                    f7      38      Inital ft7
                    f8      39      Inital fs0
                    f9      40      Inital fs1
                    f10     41      Inital fa0
                    f11     42      Inital fa1
                    f12     43      Inital fa2
                    f13     44      Inital fa3
                    f14     45      Inital fa4
                    f15     46      Inital fa5
                    f16     47      Inital fa6
                    f17     48      Inital fa7
                    f18     49      Inital fs2
                    f19     50      Inital fs3
                    f20     51      Inital fs4
                    f21     52      Inital fs5
                    f22     53      Inital fs6
                    f23     54      Inital fs7
                    f24     55      Inital fs8
                    f25     56      Inital fs9
                    f26     57      Inital fs10
                    f27     58      Inital fs11
                    f28     59      Inital ft8
                    f29     60      Inital ft9
                    f30     61      Inital ft10
                    f31     62      Inital ft11
                    fscr    63      Inital fscr

    Stack Bottom: (higher memory address)  */

    lw      t0, 4*4(a0)                                   // Pickup end of stack area
    li      t1, ~15                                       // Build 16-byte alignment mask
    and     t0, t0, t1                                    // Make sure 16-byte alignment

    /* Actually build the stack frame.  */

#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    addi    t0, t0, -65*4
#else
    addi    t0, t0, -32*4                                 // Allocate space for the stack frame
#endif
    li      t1, 1                                         // Build stack type
    sw      t1,  0*4(t0)                                  // Place stack type on the top
    sw      zero,  1*4(t0)                                // Initial s11
    sw      zero,  2*4(t0)                                // Initial s10
    sw      zero,  3*4(t0)                                // Initial s9
    sw      zero,  4*4(t0)                                // Initial s8
    sw      zero,  5*4(t0)                                // Initial s7
    sw      zero,  6*4(t0)                                // Initial s6
    sw      zero,  7*4(t0)                                // Initial s5
    sw      zero,  8*4(t0)                                // Initial s4
    sw      zero,  9*4(t0)                                // Initial s3
    sw      zero, 10*4(t0)                                // Initial s2
    sw      zero, 11*4(t0)                                // Initial s1
    sw      zero, 12*4(t0)                                // Initial s0
    sw      zero, 13*4(t0)                                // Initial t6
    sw      zero, 14*4(t0)                                // Initial t5
    sw      zero, 15*4(t0)                                // Initial t4
    sw      zero, 16*4(t0)                                // Initial t3
    sw      zero, 17*4(t0)                                // Initial t2
    sw      zero, 18*4(t0)                                // Initial t1
    sw      zero, 19*4(t0)                                // Initial t0
    sw      zero, 20*4(t0)                                // Initial a7
    sw      zero, 21*4(t0)                                // Initial a6
    sw      zero, 22*4(t0)                                // Initial a5
    sw      zero, 23*4(t0)                                // Initial a4
    sw      zero, 24*4(t0)                                // Initial a3
    sw      zero, 25*4(t0)                                // Initial a2
    sw      zero, 26*4(t0)                                // Initial a1
    sw      zero, 27*4(t0)                                // Initial a0
    sw      zero, 28*4(t0)                                // Initial ra
    sw      a1, 30*4(t0)                                  // Initial mepc
#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    sw      zero, 31*4(t0)                                // Inital ft0
    sw      zero, 32*4(t0)                                // Inital ft1
    sw      zero, 33*4(t0)                                // Inital ft2
    sw      zero, 34*4(t0)                                // Inital ft3
    sw      zero, 35*4(t0)                                // Inital ft4
    sw      zero, 36*4(t0)                                // Inital ft5
    sw      zero, 37*4(t0)                                // Inital ft6
    sw      zero, 38*4(t0)                                // Inital ft7
    sw      zero, 39*4(t0)                                // Inital fs0
    sw      zero, 40*4(t0)                                // Inital fs1
    sw      zero, 41*4(t0)                                // Inital fa0
    sw      zero, 42*4(t0)                                // Inital fa1
    sw      zero, 43*4(t0)                                // Inital fa2
    sw      zero, 44*4(t0)                                // Inital fa3
    sw      zero, 45*4(t0)                                // Inital fa4
    sw      zero, 46*4(t0)                                // Inital fa5
    sw      zero, 47*4(t0)                                // Inital fa6
    sw      zero, 48*4(t0)                                // Inital fa7
    sw      zero, 49*4(t0)                                // Inital fs2
    sw      zero, 50*4(t0)                                // Inital fs3
    sw      zero, 51*4(t0)                                // Inital fs4
    sw      zero, 52*4(t0)                                // Inital fs5
    sw      zero, 53*4(t0)                                // Inital fs6
    sw      zero, 54*4(t0)                                // Inital fs7
    sw      zero, 55*4(t0)                                // Inital fs8
    sw      zero, 56*4(t0)                                // Inital fs9
    sw      zero, 57*4(t0)                                // Inital fs10
    sw      zero, 58*4(t0)                                // Inital fs11
    sw      zero, 59*4(t0)                                // Inital ft8
    sw      zero, 60*4(t0)                                // Inital ft9
    sw      zero, 61*4(t0)                                // Inital ft10
    sw      zero, 62*4(t0)                                // Inital ft11
    csrr    a1, fcsr                                      // Read fcsr and use it for initial value for each thread
    sw      a1, 63*4(t0)                                  // Initial fscr
    sw      zero, 64*4(t0)                                // Reserved word (0)
#else
    sw      zero, 31*4(t0)                                // Reserved word (0)
#endif

    /* Setup stack pointer.  */
    /* thread_ptr -> tx_thread_stack_ptr =  t0;  */

    sw      t0, 2*4(a0)                                   // Save stack pointer in thread's
    ret                                                   // control block and return
/* }  */
