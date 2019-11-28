				.include "address_map_arm.s"
				.extern	LEDR_DIRECTION
				.extern	LEDR_PATTERN

/*****************************************************************************
 * MPCORE Private Timer - Interrupt Service Routine                                
 *                                                                          
 * Shifts the pattern being displayed on the LEDR
 * 
******************************************************************************/
				.global PRIV_TIMER_ISR
PRIV_TIMER_ISR:	
				LDR		R0, =MPCORE_PRIV_TIMER	// base address of timer
				MOV		R1, #1
				STR		R1, [R0, #0xC]				// write 1 to F bit to reset it
															// and clear the interrupt

/* Move the two LEDS to the centre or away from the centre to the outside. */
SWEEP:			LDR		R0, =LEDR_DIRECTION	// put shifting direction into R2
				LDR		R2, [R0]
				LDR		R1, =LEDR_PATTERN		// put LEDR pattern into R3
				LDR		R3, [R1]
				MOV     R4, #0x201 // Pattern for LEDs on the outside
				CMP     R4, R3
				BEQ		O_C  // LEDs are at outside, change direction to center
				MOV 	R4, #0x30 // Pattern for LEDs on the inside
				CMP     R4, R3
				BEQ     C_O // LEDs are at center, change direction to outside
				CMP     R2, #0
				BEQ     TOCENTRE // If direction is equal to 0, moving towards center
				B       TOOUTSIDE // Otherwise, moving towards outside

TOCENTRE:		LDR R4, =0x201 // Load each possible pattern
				CMP R4, R3 // Compare them to LEDR pattern in R3
				LDREQ R3, =0x102 // If equal, update pattern by moving to next one towards center
				BEQ DONE_SWEEP // Finsh sweep

				LDR R4, =0x102
				CMP R4, R3
				MOVEQ R3, #0x84
				BEQ DONE_SWEEP

				CMP R3, #0x84
				MOVEQ R3, =0x48
				BEQ DONE_SWEEP

				MOV R3, #0x30 // No possible combinations left, move R3 to inside pattern
				B   DONE_SWEEP

C_O:			MOV		R2, #1					// change direction to outside

TOOUTSIDE:		CMP R3, #0x30 // Compare each possible pattern to LEDR pattern in R3
				MOVEQ R3, #0x48 // Move R3 to next pattern towards outside if it matches
				BEQ DONE_SWEEP // Finish sweep

				CMP R3, #0x48
				MOVEQ R3, #0x84
				BEQ DONE_SWEEP

				// LDR R4, =0x102
				CMP R3, #0x84
				LDREQ R3, =0x102 //R4
				BEQ DONE_SWEEP

				LDR R3, =0x201 // No possible combinations left, move R3 to outside pattern
				B DONE_SWEEP 

O_C:			MOV		R2, #0					// change direction to centre
				B			TOCENTRE

DONE_SWEEP:
				STR		R2, [R0]					// put shifting direction back into memory
				STR		R3, [R1]					// put LEDR pattern back onto stack
	
END_TIMER_ISR:
				MOV		PC, LR
