		.equ		CPU0,         				0x01	// bit-mask; bit 0 represents cpu0
		.equ	KEYS_IRQ, 						73
		.equ   MPCORE_GIC_CPUIF,     0xFFFEC100   /* PERIPH_BASE + 0x100 */
        .equ   ICCICR,               0x00         /* CPU interface control register */
        .equ   ICCPMR,               0x04         /* interrupt priority mask register */
        .equ   ICCIAR,               0x0C         /* interrupt acknowledge register */
        .equ   ICCEOIR,              0x10         /* end of interrupt register */

.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

				.text
								.global	SERVICE_IRQ
SERVICE_IRQ:
				/* save R0-R3, because subroutines called from here might modify
				   these registers without saving/restoring them. Save R4, R5
					because we modify them in this subroutine */
    			PUSH		{R0-R5, LR}
    
    			/* Read the ICCIAR from the CPU interface */
    			LDR		R4, =MPCORE_GIC_CPUIF
    			LDR		R5, [R4, #ICCIAR] 			// read the interrupt ID
				CMP R5, #KEYS_IRQ
				BNE EXIT_IRQ

KEYS_CHECK: 
				LDR R0, =0xFF200050
				LDR R1, [R0,#0xC]
				STR R1, [R0, #0xC]		
				MOV R3, #0x1
				ANDS R3, R1
				BEQ EXIT_IRQ
				LDR R0, =KEY_PRESSED
				LDR R1, [R0]	
				EOR R1, #0x1
				STR R1, [R0]
EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #ICCEOIR]
    
    			POP		{R0-R5, LR}
    			SUBS		PC, LR, #4						// return from interrupt


/*--- Undefined instructions --------------------------------------------------*/
				.global	SERVICE_UND
SERVICE_UND:
    			B			SERVICE_UND 
 
/*--- Software interrupts -----------------------------------------------------*/
				.global	SERVICE_SVC
SERVICE_SVC:				
    			B			SERVICE_SVC 

/*--- Aborted data reads ------------------------------------------------------*/
				.global	SERVICE_ABT_DATA
SERVICE_ABT_DATA:
    			B			SERVICE_ABT_DATA 

/*--- Aborted instruction fetch -----------------------------------------------*/
				.global	SERVICE_ABT_INST
SERVICE_ABT_INST:
    			B			SERVICE_ABT_INST 
 
/*--- FIQ ---------------------------------------------------------------------*/
				.global	SERVICE_FIQ
SERVICE_FIQ:
    			B			SERVICE_FIQ 

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
				.global	CONFIG_GIC
CONFIG_GIC:
				PUSH		{LR}
    			/* Configure the KEYs
				/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
    			MOV		R0, #KEYS_IRQ
    			MOV		R1, #CPU0
    			BL			CONFIG_INTERRUPT

				/* configure the GIC CPU interface */
    			LDR		R0, =0xFFFEC100		// base address of CPU interface
    			/* Set Interrupt Priority Mask Register (ICCPMR) */
    			LDR		R1, =0xFFFF 			// enable interrupts of all priorities levels
    			STR		R1, [R0, #0x04]
    			/* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
				 * allows interrupts to be forwarded to the CPU(s) */
    			MOV		R1, #1
    			STR		R1, [R0]
    
    			/* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
				 * allows the distributor to forward interrupts to the CPU interface(s) */
    			LDR		R0, =0xFFFED000
    			STR		R1, [R0]    
    
    			POP     	{PC}
CONFIG_KEYS:
			LDR 		R0, =0xFF200050 		// KEYs base address
			MOV R1, #0x1
			STR R1, [R0, #0x8]
			MOV 		PC, LR 					// return
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
    			PUSH		{R4-R5, LR}
    
    			/* Configure Interrupt Set-Enable Registers (ICDISERn). 
				 * reg_offset = (integer_div(N / 32) * 4
				 * value = 1 << (N mod 32) */
    			LSR		R4, R0, #3							// calculate reg_offset
    			BIC		R4, R4, #3							// R4 = reg_offset
				LDR		R2, =0xFFFED100
				ADD		R4, R2, R4							// R4 = address of ICDISER
    
    			AND		R2, R0, #0x1F   					// N mod 32
				MOV		R5, #1								// enable
    			LSL		R2, R5, R2							// R2 = value

				/* now that we have the register address (R4) and value (R2), we need to set the
				 * correct bit in the GIC register */
    			LDR		R3, [R4]								// read current register value
    			ORR		R3, R3, R2							// set the enable bit
    			STR		R3, [R4]								// store the new register value

    			/* Configure Interrupt Processor Targets Register (ICDIPTRn)
     			 * reg_offset = integer_div(N / 4) * 4
     			 * index = N mod 4 */
    			BIC		R4, R0, #3							// R4 = reg_offset
				LDR		R2, =0xFFFED800
				ADD		R4, R2, R4							// R4 = word address of ICDIPTR
    			AND		R2, R0, #0x3						// N mod 4
				ADD		R4, R2, R4							// R4 = byte address in ICDIPTR

				/* now that we have the register address (R4) and value (R2), write to (only)
				 * the appropriate byte */
				STRB		R1, [R4]
    
    			POP		{R4-R5, PC}
				
				.global _start
_start:
				MOV R0, #0b11010010
				MSR CPSR, R0
				LDR SP, =0x20000
				MOV R0, #0b11010011
				MSR CPSR, R0
				LDR SP, =0x3FFFFFFC
				BL			CONFIG_GIC				// configure the ARM generic interrupt controller
				BL			CONFIG_KEYS	
				MOV R0, #0b01010011
				MSR CPSR, R0
				LDR R4, =0xFF200020
				LDR R5, =0xFFFEC600
				MOV R6, #0x09
				LDR R0, =200000000
				STR R0, [R5]
				MOV R0, #0b011
				STR R0, [R5,#8]
DISPLAY: 
				LDR R7, =KEY_PRESSED
				LDR R8, [R7]
				CMP R8, #0x1
				BNE NEG
				MOV R9, #1
				B NEXT
NEG: 			MOV R9, #-1
NEXT:			MOV R0, R6
				BL MY_HEX
				STR R0, [R4]
				SUB R6, R6, R9
				CMP R6, #0xA
				BNE ZERO1
				MOV R6, #0x0
				B DELAY
ZERO1: 			CMP R6, #0x0
				BGE DELAY
				MOV R6, #0x09
DELAY: 			LDR R0, [R5, #0xC]
				CMP R0, #0
				BEQ DELAY
				STR R0, [R5, #0xC]
				B DISPLAY
MY_HEX: 		CMP R0, #9
				BNE EIGHT
				MOV R0, #0x6F
				B RETURN
EIGHT:			CMP R0, #8
				BNE SEVEN
				MOV R0, #0x7F
				B RETURN
SEVEN: 			CMP R0, #7
				BNE SIX
				MOV R0, #0x07
				B RETURN
SIX:			CMP R0, #6
				BNE FIVE
				MOV R0, #0x7D
				B RETURN
FIVE: 			CMP R0, #5
				BNE FOUR
				MOV R0, #0x6D
				B RETURN
FOUR:			CMP R0, #4
				BNE THREE
				MOV R0, #0x66
				B RETURN
THREE: 			CMP R0, #3
				BNE TWO
				MOV R0, #0x4F
				B RETURN
TWO: 			CMP R0, #2
				BNE ONE
				MOV R0, #0x5B
				B RETURN
ONE: 			CMP R0, #1
				BNE ZERO
				MOV R0, #0x06
				B RETURN
ZERO:	 		MOV R0, #0x3F
RETURN: 		MOV PC, LR
.section .data
KEY_PRESSED: .word 0