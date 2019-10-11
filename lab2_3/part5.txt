module part5 (SW, LEDR, HEX0, HEX1, HEX2);
	input [9:0] SW; // slide switches
	output [9:0] LEDR; // red lights
	output [6:0] HEX0; // 7-seg display
	output [6:0] HEX1; // 7-seg display
	output [6:0] HEX2; // 7-seg display

	wire [1:0] M0, M1, M2;

	assign LEDR[0] = SW[0];
	assign LEDR[1] = SW[1];
	assign LEDR[2] = SW[2];
	assign LEDR[3] = SW[3];
	assign LEDR[4] = SW[4];
	assign LEDR[5] = SW[5];
	assign LEDR[6] = SW[6];
	assign LEDR[7] = SW[7];
	assign LEDR[8] = SW[8];

	mux_2bit_3to1 U0 (SW[9:8], SW[5:4], SW[3:2], SW[1:0], M0);
	mux_2bit_3to1 U1 (SW[9:8], SW[5:4], SW[3:2], SW[1:0], M1);
	mux_2bit_3to1 U2 (SW[9:8], SW[5:4], SW[3:2], SW[1:0], M2);

	char_7seg H0 (M0, HEX0);
	char_7seg H1 (M1, HEX1);
	char_7seg H2 (M2, HEX2);

endmodule

// implements a 2-bit wide 3-to-1 multiplexer
module mux_2bit_3to1 (S, U, V, W, M);
	input [1:0] S, U, V, W;
	output [1:0] M;
	assign M = ({~S[0], ~S[0]} & {~S[1], ~S[1]} & U) | ({~S[0], ~S[0]} & {S[1], S[1]} & V) | ({S[0], S[0]} & W);

endmodule

// implements a 7-segment decoder for 2, 5, 3 and ‘blank’
module char_7seg (C, Display);
	input [1:0] C; // input code
	output [6:0] Display; // output 7-seg code

	assign Display[0] = C[0] & C[1];
	assign Display[1] = C[0];
	assign Display[2] = ~(C[0] ^ C[1]);
	assign Display[3] = C[0] & C[1];
	assign Display[4] = C[0] | C[1];
	assign Display[5] = ~C[0] | C[1];
	assign Display[6] = C[0] & C[1];

endmodule
