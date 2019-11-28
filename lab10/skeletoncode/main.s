	.include "address_map_arm.s"
/* 
 * This program demonstrates the use of interrupts using the KEY and timer ports. It
 * 	1. displays a sweeping red light on LEDR, which moves left and right
 * 	2. stops/starts the sweeping motion if KEY3 is pressed
 * Both the timer and KEYs are handled via interrupts
*/
			.text
			.global	_start
_start:
			/* Initializing IRQ stack pointer - note: SP is different for each mode */
			MOV R0, #0b10111 // Move current program status register (CPSR) bits for IRQ mode into R0
			MSR CPSR, R0 // Change to IRQ (interrupt request) mode
			LDR SP, =0x20000 // Set stack pointer to address far from in-use memory

			/* Initializing SVC (supervisor) stack pointer */
			MOV R0, #0b10011 // SVC mode bits
			MSR CPSR, R0 // Change to SVC mode 
			LDR SP, =0x3FFFFFFC // Load address far from in-use memory for SVC stack pointer

			BL			CONFIG_GIC				// configure the ARM generic interrupt controller
			BL			CONFIG_PRIV_TIMER		// configure the MPCore private timer
			BL			CONFIG_KEYS				// configure the pushbutton KEYs
			
			// Set interrupt mask bit (7th bit) in CPSR to 0 (enable interrupts in ARM processor)
			MSR CPSR, #0b00010011

			LDR		R6, =0xFF200000 		// red LED base address
MAIN:
			LDR		R4, LEDR_PATTERN		// LEDR pattern; modified by timer ISR
			STR 		R4, [R6] 				// write to red LEDs
			B 			MAIN

/* Configure the MPCore private timer to create interrupts every 1/10 second */
CONFIG PRIV TIMER:
			LDR	R0, =0xFFFEC600 		// Timer base address
			LDR R1, =50000000 			// Counter value to give 0.25 seconds count for 500mHz clock
			STR R1, [R0] 				// Store initial count at timer base address (load value)
			MOV R1, #0b111 				// Interrupt = 1 (enables interrupts), Auto-reload = 1, enable = 1 (begin timing)
			STR R1, [R0, #8] 			// Store config settings in control register
			MOV PC, LR 					// Return

/* Configure the KEYS to generate an interrupt */
CONFIG KEYS:
			LDR R0, =0xFF200050 		// KEYs base address
			MOV R1, 0x8					// 3rd bit of R1 is 1, indicating only KEY3 should cause interrupts 
			STR R1, [R0, #0x8]			// Store value of R1 in interrupt mask register
			MOV PC, LR 					// Return

			.global	LEDR_DIRECTION
LEDR_DIRECTION:
			.word 	0							// 0 means means moving to centre; 1 means moving to outside

			.global	LEDR_PATTERN
LEDR_PATTERN:
			.word 	0x201	// 1000000001
