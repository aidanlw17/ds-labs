/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed.  If KEY3 it stops/starts the timer.
****************************************************************************************/
					.global	KEY_ISR
KEY_ISR: 		LDR		R0, =KEY_BASE			// base address of KEYs parallel port
				LDR		R1, [R0, #0xC]			// read edge capture register
				STR		R1, [R0, #0xC]			// clear the interrupt

CHK_KEY3:		MOV 	R3, #0x8    // Set 3rd bit to 1
				ANDS 	R3, R1      // Check if KEY3 sent interrupt in edge capture register (3rd bit)
				BNE 	START_STOP  // If z flag not 1, KEY3 pressed, go to START_STOP
				B 		END_KEY_ISR // Otherwise go to end of routine

START_STOP:		LDR		R0, =MPCORE_PRIV_TIMER	// timer base address
				LDR		R1, [R0, #0x8]			// read timer control register
				MOV     R2, #0b1				// Set 0th bit to 1
				EOR     R1, R2					// Invert 0th bit of R1 (invert enable)
				STR     R1, [R0, #0x8]			// Store inverted R1 in control register

END_KEY_ISR:	MOV	PC, LR
				.end
