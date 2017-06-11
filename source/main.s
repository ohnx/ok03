/******************************************************************************
*	main.s
*	 by Alex Chadwick
*
*	A sample assembly code implementation of the ok03 operating system, that 
*	simply turns the OK LED on and off repeatedly, but now using the EABI 
*   standard, and procedure calls. Also new is an appreciation of the IVT.
*	Sections changed since ok02.s are marked with NEW.
*
*	main.s contains the main operating system, and IVT code.
******************************************************************************/

/*
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.globl _start
_start:

/* NEW
* Branch to the actual main code.
*/
b main

/* NEW
* This command tells the assembler to put this code with the rest.
*/
.section .text

/* NEW
* main is what we shall call our main operating system method. It never 
* returns, and takes no parameters.
* C++ Signature: void main(void)
*/
main:

/* NEW
* Set the stack point to 0x8000.
*/
mov sp,#0x8000

mov r12,#0x20 @ 32
enable_loop:
    sub r12,#0x1

    /* NEW
     * Use our new SetGpioFunction function to set the function of
     * GPIO port (r12) to 001 (binary)
     */
    pinNum .req r0
    pinFunc .req r1
    mov pinNum,r12
    mov pinFunc,#1
    bl SetGpioFunction
    .unreq pinNum
    .unreq pinFunc

    @ keep looping until we have enabled all GPIO pins
    cmp r12,#0x0
    bne enable_loop

loop$:

mov r12,#0x20 @ 32
turnon_loop:
    sub r12,#0x1

    /* NEW
     * Use our new SetGpio function to set GPIO (r12) to high, causing the LED to turn 
     * on.
     */

     pinNum .req r0
     pinVal .req r1
     mov pinNum,r12
     mov pinVal,#1
     bl SetGpio
     .unreq pinNum
     .unreq pinVal

     @ keep looping until we have turned on all GPIO pins
     cmp r12,#0x0
     bne turnon_loop

/*
* Now, to create a delay, we busy the processor on a pointless quest to 
* decrement the number 0x3F0000 to 0!
*/
decr .req r0
mov decr,#0x3F0000
wait1$:
	sub decr,#1
	teq decr,#0
	bne wait1$
.unreq decr

mov r12,#0x20 @ 32
turnoff_loop:
    sub r12,#0x1
    /* NEW
     * Use our new SetGpio function to set GPIO r12 to low, causing the LED to turn 
     * off.
     */
    pinNum .req r0
    pinVal .req r1
    mov pinNum,r12
    mov pinVal,#0
    bl SetGpio
    .unreq pinNum
    .unreq pinVal

     @ keep looping until we have turned off all GPIO pins
     cmp r12,#0x0
     bne turnon_loop

/*
* Wait once more.
*/
decr .req r0
mov decr,#0x3F0000
wait2$:
	sub decr,#1
	teq decr,#0
	bne wait2$
.unreq decr

/*
* Loop over this process forevermore
*/
b loop$
