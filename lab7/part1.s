.data
TEST_NUM: .word 1, 2, 3, 4, 0xA, -1

.text
.global _start

_start:
	LDR R1, = TEST_NUM
	MOV R7, #0
	MOV R8, #0
	loop:
		LDR R1, [R1], #4
		CMP R1, #-1
		BEQ end
		CMP R1, #0
		ADDGT R7, R7, R1
		CMP R1, #0
		ADDGT R8, R8, #1

end:
	b end

.end
