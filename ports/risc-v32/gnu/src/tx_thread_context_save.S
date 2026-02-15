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
/*    _tx_thread_context_save                            RISC-V32/GNU     */
/*                                                           6.4.x        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    Akif Ejaz, 10xEngineers                                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function saves the context of an executing thread in the       */
/*    beginning of interrupt processing.  The function also ensures that  */
/*    the system stack is used upon return to the calling ISR.            */
/*                                                                        */
/*  INPUT                                                                 */
/*                                                                        */
/*    None                                                                */
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
/*    ISRs                                                                */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  23-12-2025        Akif Ejaz            Initial Version 6.4.x          */
/*                                                                        */
/**************************************************************************/
/* VOID   _tx_thread_context_save(VOID)
{  */
    .global      _tx_thread_context_save
_tx_thread_context_save:

    /* Upon entry to this routine, it is assumed that interrupts are locked
       out and the interrupt stack frame has been allocated and ra has
       been saved on the stack. */

    sw     t0, 19*4(sp)                                 // First store t0 and t1
    sw     t1, 18*4(sp)

    la      t0, _tx_thread_system_state                 // Pickup address of system state
    Lw      t1, 0(t0)                                   // Pickup system state

    /* Check for a nested interrupt condition.  */
    /* if (_tx_thread_system_state++)
    {  */
    beqz    t1, _tx_thread_not_nested_save              // If 0, first interrupt condition
    addi    t1, t1, 1                                   // Increment the interrupt counter
    sw      t1, 0(t0)                                   // Store the interrupt counter

    /* Nested interrupt condition.
       Save the rest of the scratch registers on the stack and return to the
       calling ISR.  */

    sw      t2,  17*4(sp)                               // Store t2
    sw      s0,  12*4(sp)                               // Store s0
    sw      a0,  27*4(sp)                               // Store a0
    sw      a1,  26*4(sp)                               // Store a1
    sw      a2,  25*4(sp)                               // Store a2
    sw      a3,  24*4(sp)                               // Store a3
    sw      a4,  23*4(sp)                               // Store a4
    sw      a5,  22*4(sp)                               // Store a5
    sw      a6,  21*4(sp)                               // Store a6
    sw      a7,  20*4(sp)                               // Store a7
    sw      t3,  16*4(sp)                               // Store t3
    sw      t4,  15*4(sp)                               // Store t4
    sw      t5,  14*4(sp)                               // Store t5
    sw      t6,  13*4(sp)                               // Store t6
    csrr    t0, mepc                                    // Load exception program counter
    sw      t0, 30*4(sp)                                // Save it on the stack

    /* Save floating point scratch registers if floating point is enabled.  */
#ifdef __riscv_float_abi_single
    fsw     f0, 31*4(sp)                         // Store ft0
    fsw     f1, 32*4(sp)                         // Store ft1
    fsw     f2, 33*4(sp)                         // Store ft2
    fsw     f3, 34*4(sp)                         // Store ft3
    fsw     f4, 35*4(sp)                         // Store ft4
    fsw     f5, 36*4(sp)                         // Store ft5
    fsw     f6, 37*4(sp)                         // Store ft6
    fsw     f7, 38*4(sp)                         // Store ft7
    fsw     f10,41*4(sp)                         // Store fa0
    fsw     f11,42*4(sp)                         // Store fa1
    fsw     f12,43*4(sp)                         // Store fa2
    fsw     f13,44*4(sp)                         // Store fa3
    fsw     f14,45*4(sp)                         // Store fa4
    fsw     f15,46*4(sp)                         // Store fa5
    fsw     f16,47*4(sp)                         // Store fa6
    fsw     f17,48*4(sp)                         // Store fa7
    fsw     f28,59*4(sp)                         // Store ft8
    fsw     f29,60*4(sp)                         // Store ft9
    fsw     f30,61*4(sp)                         // Store ft10
    fsw     f31,62*4(sp)                         // Store ft11
    csrr    t0, fcsr
    sw      t0, 63*4(sp)                         // Store fcsr
#elif defined(__riscv_float_abi_double)
    fsd     f0, 31*4(sp)                         // Store ft0
    fsd     f1, 32*4(sp)                         // Store ft1
    fsd     f2, 33*4(sp)                         // Store ft2
    fsd     f3, 34*4(sp)                         // Store ft3
    fsd     f4, 35*4(sp)                         // Store ft4
    fsd     f5, 36*4(sp)                         // Store ft5
    fsd     f6, 37*4(sp)                         // Store ft6
    fsd     f7, 38*4(sp)                         // Store ft7
    fsd     f10,41*4(sp)                         // Store fa0
    fsd     f11,42*4(sp)                         // Store fa1
    fsd     f12,43*4(sp)                         // Store fa2
    fsd     f13,44*4(sp)                         // Store fa3
    fsd     f14,45*4(sp)                         // Store fa4
    fsd     f15,46*4(sp)                         // Store fa5
    fsd     f16,47*4(sp)                         // Store fa6
    fsd     f17,48*4(sp)                         // Store fa7
    fsd     f28,59*4(sp)                         // Store ft8
    fsd     f29,60*4(sp)                         // Store ft9
    fsd     f30,61*4(sp)                         // Store ft10
    fsd     f31,62*4(sp)                         // Store ft11
    csrr    t0, fcsr
    sw      t0, 63*4(sp)                         // Store fcsr
#endif

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    call    _tx_execution_isr_enter                     // Call the ISR execution enter function
#endif

    ret                                                 // Return to calling ISR

_tx_thread_not_nested_save:
    /* }  */

    /* Otherwise, not nested, check to see if a thread was running.  */
    /* else if (_tx_thread_current_ptr)
    {  */
    addi    t1, t1, 1                                   // Increment the interrupt counter
    sw      t1, 0(t0)                                   // Store the interrupt counter

    /* Not nested: Find the user thread that was running and load our SP */

    la      t0, _tx_thread_current_ptr                  // Pickup current thread pointer address
    lw      t0, 0(t0)                                   // Pickup current thread pointer
    beqz    t0, _tx_thread_idle_system_save             // If NULL, idle system was interrupted

    /* Save the standard scratch registers.  */

    sw      t2,  17*4(sp)                               // Store t2
    sw      s0,  12*4(sp)                               // Store s0
    sw      a0,  27*4(sp)                               // Store a0
    sw      a1,  26*4(sp)                               // Store a1
    sw      a2,  25*4(sp)                               // Store a2
    sw      a3,  24*4(sp)                               // Store a3
    sw      a4,  23*4(sp)                               // Store a4
    sw      a5,  22*4(sp)                               // Store a5
    sw      a6,  21*4(sp)                               // Store a6
    sw      a7,  20*4(sp)                               // Store a7
    sw      t3,  16*4(sp)                               // Store t3
    sw      t4,  15*4(sp)                               // Store t4
    sw      t5,  14*4(sp)                               // Store t5
    sw      t6,  13*4(sp)                               // Store t6

    csrr    t0, mepc                                    // Load exception program counter
    sw      t0, 30*4(sp)                                // Save it on the stack

    /* Save floating point scratch registers if floating point is enabled  */
#if defined(__riscv_float_abi_single)
    fsw     f0, 31*4(sp)                         // Store ft0
    fsw     f1, 32*4(sp)                         // Store ft1
    fsw     f2, 33*4(sp)                         // Store ft2
    fsw     f3, 34*4(sp)                         // Store ft3
    fsw     f4, 35*4(sp)                         // Store ft4
    fsw     f5, 36*4(sp)                         // Store ft5
    fsw     f6, 37*4(sp)                         // Store ft6
    fsw     f7, 38*4(sp)                         // Store ft7
    fsw     f10,41*4(sp)                         // Store fa0
    fsw     f11,42*4(sp)                         // Store fa1
    fsw     f12,43*4(sp)                         // Store fa2
    fsw     f13,44*4(sp)                         // Store fa3
    fsw     f14,45*4(sp)                         // Store fa4
    fsw     f15,46*4(sp)                         // Store fa5
    fsw     f16,47*4(sp)                         // Store fa6
    fsw     f17,48*4(sp)                         // Store fa7
    fsw     f28,59*4(sp)                         // Store ft8
    fsw     f29,60*4(sp)                         // Store ft9
    fsw     f30,61*4(sp)                         // Store ft10
    fsw     f31,62*4(sp)                         // Store ft11
    csrr    t0, fcsr
    sw      t0, 63*4(sp)                         // Store fcsr
#elif defined(__riscv_float_abi_double)
    fsd     f0, 31*4(sp)                         // Store ft0
    fsd     f1, 32*4(sp)                         // Store ft1
    fsd     f2, 33*4(sp)                         // Store ft2
    fsd     f3, 34*4(sp)                         // Store ft3
    fsd     f4, 35*4(sp)                         // Store ft4
    fsd     f5, 36*4(sp)                         // Store ft5
    fsd     f6, 37*4(sp)                         // Store ft6
    fsd     f7, 38*4(sp)                         // Store ft7
    fsd     f10,41*4(sp)                         // Store fa0
    fsd     f11,42*4(sp)                         // Store fa1
    fsd     f12,43*4(sp)                         // Store fa2
    fsd     f13,44*4(sp)                         // Store fa3
    fsd     f14,45*4(sp)                         // Store fa4
    fsd     f15,46*4(sp)                         // Store fa5
    fsd     f16,47*4(sp)                         // Store fa6
    fsd     f17,48*4(sp)                         // Store fa7
    fsd     f28,59*4(sp)                         // Store ft8
    fsd     f29,60*4(sp)                         // Store ft9
    fsd     f30,61*4(sp)                         // Store ft10
    fsd     f31,62*4(sp)                         // Store ft11
    csrr    t0, fcsr
    sw      t0, 63*4(sp)                         // Store fcsr
#endif

    /* Save the current stack pointer in the thread's control block.  */
    /* _tx_thread_current_ptr -> tx_thread_stack_ptr =  sp;  */

    /* Switch to the system stack.  */
    /* sp =  _tx_thread_system_stack_ptr;  */

    la      t1, _tx_thread_current_ptr           // Pickup current thread pointer address
    lw      t1, 0(t1)                            // Pickup current thread pointer
    sw      sp, 2*4(t1)                          // Save stack pointer

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    /* _tx_execution_isr_enter is called with thread stack pointer */
    call    _tx_execution_isr_enter                     // Call the ISR execution enter function
#endif

    la      t0, _tx_thread_system_stack_ptr             // Pickup system stack pointer address
    lw      sp, 0(t0)                                   // Switch to system stack
    ret                                                 // Return to calling ISR

    /* }
    else
    {  */

_tx_thread_idle_system_save:


#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    call    _tx_execution_isr_enter                     // Call the ISR execution enter function
#endif

    /* Interrupt occurred in the scheduling loop.  */

    /* }
}  */
#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    addi    sp, sp, 65*4                               // Recover stack frame - with floating point enabled
#else
    addi    sp, sp, 32*4                               // Recover the reserved stack space
#endif
    ret                                                // Return to calling ISR
