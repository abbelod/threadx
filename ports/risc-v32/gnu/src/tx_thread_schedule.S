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
/*    _tx_thread_schedule                                RISC-V32/GNU     */
/*                                                           6.4.x        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    Akif Ejaz, 10xEngineers                                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function waits for a thread control block pointer to appear in */
/*    the _tx_thread_execute_ptr variable.  Once a thread pointer appears */
/*    in the variable, the corresponding thread is resumed.               */
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
/*    _tx_initialize_kernel_enter          ThreadX entry function         */
/*    _tx_thread_system_return             Return to system from thread   */
/*    _tx_thread_context_restore           Restore thread's context       */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  23-12-2025        Akif Ejaz            Initial Version 6.4.x          */
/*                                                                        */
/**************************************************************************/
/* VOID   _tx_thread_schedule(VOID)
{  */
    .global  _tx_thread_schedule
_tx_thread_schedule:

    /* Enable interrupts.  */
    csrsi   mstatus, 0x08                               // Enable interrupts (MIE bit 3)

    /* Wait for a thread to execute.  */
    /* do
    {  */

    la      t0, _tx_thread_execute_ptr                  // Pickup address of execute ptr
_tx_thread_schedule_loop:
    lw      t1, 0(t0)                                   // Pickup next thread to execute

/* TX_USE_WFI_IDLE Configuration:
       When defined, the scheduler enters WFI (Wait-For-Interrupt) mode when
       no threads are ready, reducing power consumption. The core will wake
       on any enabled interrupt. This is recommended for battery-powered or
       low-power applications. Define TX_USE_WFI_IDLE in tx_user.h or via
       compiler flags to enable this feature.  */
    
#ifdef TX_USE_WFI_IDLE
    beqz    t1, 1f
    j 2f
1:  wfi
    j _tx_thread_schedule_loop
2:
    beqz    t1, _tx_thread_schedule_loop                // Fallback: If still NULL, loop
#else
    beqz    t1, _tx_thread_schedule_loop                // If NULL, wait for thread to execute
#endif

    beqz    t1, _tx_thread_schedule_loop                // If NULL, wait for thread to execute

    /* }
    while(_tx_thread_execute_ptr == TX_NULL);  */

    /* Yes! We have a thread to execute.  Lockout interrupts and
       transfer control to it.  */
    csrci   mstatus, 0x08                               // Lockout interrupts

    /* Setup the current thread pointer.  */
    /* _tx_thread_current_ptr =  _tx_thread_execute_ptr;  */

    la      t0, _tx_thread_current_ptr                  // Pickup current thread pointer address
    sw      t1, 0(t0)                                   // Set current thread pointer

    /* Increment the run count for this thread.  */
    /* _tx_thread_current_ptr -> tx_thread_run_count++;  */

    lw      t2, 1*4(t1)                                 // Pickup run count
    lw      t3, 6*4(t1)                                 // Pickup time slice value
    addi    t2, t2, 1                                   // Increment run count
    sw      t2, 1*4(t1)                                 // Store new run count

    /* Setup time-slice, if present.  */
    /* _tx_timer_time_slice =  _tx_thread_current_ptr -> tx_thread_time_slice;  */

    la      t2, _tx_timer_time_slice                    // Pickup time-slice variable address

    /* Switch to the thread's stack.  */
    /* SP =  _tx_thread_execute_ptr -> tx_thread_stack_ptr;  */

    lw      sp, 2*4(t1)                                 // Switch to thread's stack
    sw      t3, 0(t2)                                   // Store new time-slice*/

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    call    _tx_execution_thread_enter                  // Call the thread execution enter function
#endif

    /* Determine if an interrupt frame or a synchronous task suspension frame
       is present.  */

    lw      t2, 0(sp)                                   // Pickup stack type
    beqz    t2, _tx_thread_synch_return                 // If 0, solicited thread return

    /* Determine if floating point registers need to be recovered.  */

#if defined(__riscv_float_abi_single)
    flw     f0, 31*4(sp)                                // Recover ft0
    flw     f1, 32*4(sp)                                // Recover ft1
    flw     f2, 33*4(sp)                                // Recover ft2
    flw     f3, 34*4(sp)                                // Recover ft3
    flw     f4, 35*4(sp)                                // Recover ft4
    flw     f5, 36*4(sp)                                // Recover ft5
    flw     f6, 37*4(sp)                                // Recover ft6
    flw     f7, 38*4(sp)                                // Recover ft7
    flw     f8, 39*4(sp)                                // Recover fs0
    flw     f9, 40*4(sp)                                // Recover fs1
    flw     f10,41*4(sp)                                // Recover fa0
    flw     f11,42*4(sp)                                // Recover fa1
    flw     f12,43*4(sp)                                // Recover fa2
    flw     f13,44*4(sp)                                // Recover fa3
    flw     f14,45*4(sp)                                // Recover fa4
    flw     f15,46*4(sp)                                // Recover fa5
    flw     f16,47*4(sp)                                // Recover fa6
    flw     f17,48*4(sp)                                // Recover fa7
    flw     f18,49*4(sp)                                // Recover fs2
    flw     f19,50*4(sp)                                // Recover fs3
    flw     f20,51*4(sp)                                // Recover fs4
    flw     f21,52*4(sp)                                // Recover fs5
    flw     f22,53*4(sp)                                // Recover fs6
    flw     f23,54*4(sp)                                // Recover fs7
    flw     f24,55*4(sp)                                // Recover fs8
    flw     f25,56*4(sp)                                // Recover fs9
    flw     f26,57*4(sp)                                // Recover fs10
    flw     f27,58*4(sp)                                // Recover fs11
    flw     f28,59*4(sp)                                // Recover ft8
    flw     f29,60*4(sp)                                // Recover ft9
    flw     f30,61*4(sp)                                // Recover ft10
    flw     f31,62*4(sp)                                // Recover ft11
    lw      t0, 63*4(sp)                                // Recover fcsr
    csrw    fcsr, t0                                    // Restore fcsr
#elif defined(__riscv_float_abi_double)
    fld     f0, 31*4(sp)                                // Recover ft0
    fld     f1, 32*4(sp)                                // Recover ft1
    fld     f2, 33*4(sp)                                // Recover ft2
    fld     f3, 34*4(sp)                                // Recover ft3
    fld     f4, 35*4(sp)                                // Recover ft4
    fld     f5, 36*4(sp)                                // Recover ft5
    fld     f6, 37*4(sp)                                // Recover ft6
    fld     f7, 38*4(sp)                                // Recover ft7
    fld     f8, 39*4(sp)                                // Recover fs0
    fld     f9, 40*4(sp)                                // Recover fs1
    fld     f10,41*4(sp)                                // Recover fa0
    fld     f11,42*4(sp)                                // Recover fa1
    fld     f12,43*4(sp)                                // Recover fa2
    fld     f13,44*4(sp)                                // Recover fa3
    fld     f14,45*4(sp)                                // Recover fa4
    fld     f15,46*4(sp)                                // Recover fa5
    fld     f16,47*4(sp)                                // Recover fa6
    fld     f17,48*4(sp)                                // Recover fa7
    fld     f18,49*4(sp)                                // Recover fs2
    fld     f19,50*4(sp)                                // Recover fs3
    fld     f20,51*4(sp)                                // Recover fs4
    fld     f21,52*4(sp)                                // Recover fs5
    fld     f22,53*4(sp)                                // Recover fs6
    fld     f23,54*4(sp)                                // Recover fs7
    fld     f24,55*4(sp)                                // Recover fs8
    fld     f25,56*4(sp)                                // Recover fs9
    fld     f26,57*4(sp)                                // Recover fs10
    fld     f27,58*4(sp)                                // Recover fs11
    fld     f28,59*4(sp)                                // Recover ft8
    fld     f29,60*4(sp)                                // Recover ft9
    fld     f30,61*4(sp)                                // Recover ft10
    fld     f31,62*4(sp)                                // Recover ft11
    lw      t0, 63*4(sp)                                // Recover fcsr
#endif

    /* Recover standard registers.  */

    lw      t0, 30*4(sp)                                // Recover mepc
    csrw    mepc, t0                                    // Store mepc
    li      t0, 0x1880                                  // Prepare mstatus: MPP=Machine(0x1800) | MPIE(0x80)
#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    li      t1, 0x2000                                  // Set FS bits for FP state
    or      t0, t0, t1
#endif
    csrw    mstatus, t0                                 // Set mstatus

    lw    ra,  28*4(sp)                                 // Recover return address
    lw    t0,  19*4(sp)                                 // Recover t0
    lw    t1,  18*4(sp)                                 // Recover t1
    lw    t2,  17*4(sp)                                 // Recover t2
    lw    s0,  12*4(sp)                                 // Recover s0
    lw    s1,  11*4(sp)                                 // Recover s1
    lw    a0,  27*4(sp)                                 // Recover a0
    lw    a1,  26*4(sp)                                 // Recover a1
    lw    a2,  25*4(sp)                                 // Recover a2
    lw    a3,  24*4(sp)                                 // Recover a3
    lw    a4,  23*4(sp)                                 // Recover a4
    lw    a5,  22*4(sp)                                 // Recover a5
    lw    a6,  21*4(sp)                                 // Recover a6
    lw    a7,  20*4(sp)                                 // Recover a7
    lw    s2,  10*4(sp)                                 // Recover s2
    lw    s3,  9*4(sp)                                  // Recover s3
    lw    s4,  8*4(sp)                                  // Recover s4
    lw    s5,  7*4(sp)                                  // Recover s5
    lw    s6,  6*4(sp)                                  // Recover s6
    lw    s7,  5*4(sp)                                  // Recover s7
    lw    s8,  4*4(sp)                                  // Recover s8
    lw    s9,  3*4(sp)                                  // Recover s9
    lw    s10, 2*4(sp)                                  // Recover s10
    lw    s11, 1*4(sp)                                  // Recover s11
    lw    t3,  16*4(sp)                                 // Recover t3
    lw    t4,  15*4(sp)                                 // Recover t4
    lw    t5,  14*4(sp)                                 // Recover t5
    lw    t6,  13*4(sp)                                 // Recover t6

#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    addi    sp, sp, 65*4                                // Recover stack frame - with floating point registers
#else
    addi    sp, sp, 32*4                                // Recover stack frame - without floating point registers
#endif
    mret                                                // Return to point of interrupt

_tx_thread_synch_return:

#if defined(__riscv_float_abi_single)
    flw     f8, 15*4(sp)                               // Recover fs0
    flw     f9, 16*4(sp)                               // Recover fs1
    flw     f18,17*4(sp)                               // Recover fs2
    flw     f19,18*4(sp)                               // Recover fs3
    flw     f20,19*4(sp)                               // Recover fs4
    flw     f21,20*4(sp)                               // Recover fs5
    flw     f22,21*4(sp)                               // Recover fs6
    flw     f23,22*4(sp)                               // Recover fs7
    flw     f24,23*4(sp)                               // Recover fs8
    flw     f25,24*4(sp)                               // Recover fs9
    flw     f26,25*4(sp)                               // Recover fs10
    flw     f27,26*4(sp)                               // Recover fs11
    lw      t0, 27*4(sp)                               // Recover fcsr
    csrw    fcsr, t0                                   //
#elif defined(__riscv_float_abi_double)
    fld     f8, 15*4(sp)                               // Recover fs0
    fld     f9, 16*4(sp)                               // Recover fs1
    fld     f18,17*4(sp)                               // Recover fs2
    fld     f19,18*4(sp)                               // Recover fs3
    fld     f20,19*4(sp)                               // Recover fs4
    fld     f21,20*4(sp)                               // Recover fs5
    fld     f22,21*4(sp)                               // Recover fs6
    fld     f23,22*4(sp)                               // Recover fs7
    fld     f24,23*4(sp)                               // Recover fs8
    fld     f25,24*4(sp)                               // Recover fs9
    fld     f26,25*4(sp)                               // Recover fs10
    fld     f27,26*4(sp)                               // Recover fs11
    lw      t0, 27*4(sp)                               // Recover fcsr
    csrw    fcsr, t0                                   //
#endif

    /* Recover standard preserved registers.  */
    /* Recover standard registers.  */

    lw    ra,  13*4(sp)                                // Recover RA
    lw    s0,  12*4(sp)                                // Recover s0
    lw    s1,  11*4(sp)                                // Recover s1
    lw    s2,  10*4(sp)                                // Recover s2
    lw    s3,  9*4(sp)                                 // Recover s3
    lw    s4,  8*4(sp)                                 // Recover s4
    lw    s5,  7*4(sp)                                 // Recover s5
    lw    s6,  6*4(sp)                                 // Recover s6
    lw    s7,  5*4(sp)                                 // Recover s7
    lw    s8,  4*4(sp)                                 // Recover s8
    lw    s9,  3*4(sp)                                 // Recover s9
    lw    s10,  2*4(sp)                                // Recover s10
    lw    s11,  1*4(sp)                                // Recover s11
    lw    t0,  14*4(sp)                                // Recover mstatus
    csrw  mstatus, t0                                  // Store mstatus, enables interrupt
#if defined(__riscv_float_abi_single) || defined(__riscv_float_abi_double)
    addi    sp, sp, 29*4                               // Recover stack frame
#else
    addi    sp, sp, 16*4                               // Recover stack frame
#endif
    ret                                                 // Return to thread

/* }  */
