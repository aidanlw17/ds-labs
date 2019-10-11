module lab4_part4(SW, LEDR, HEX0, HEX1, HEX4, HEX5);
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX5;

	wire z;
	wire [4:0] s;
	wire [3:0] A, B, d0_in, final_d0, final_d1;

	display_d0 x(SW[3:0], HEX5);
	display_d0 y(SW[7:4], HEX4);

	full_adder_4b(SW[3:0], SW[7:4], SW[8], s);
	assign LEDR[0] = s[0];
	assign LEDR[1] = s[1];
	assign LEDR[2] = s[2];
	assign LEDR[3] = s[3];
	assign LEDR[4] = s[4];

	comparator comp_sum(s[3:0], z);
	assign final_d1 = z | s[4];
	assign LEDR[9] = z;

	get_a a(s[3:0], A);
	get_b b(s[3:0], B);

	mux4b_2to1 mux_1(s[3:0], A, z, d0_in);
	mux4b_2to1 mux_2(d0_in, B, s[4], final_d0);

	display_d0 d0(final_d0, HEX0);
	display_d0 d1(final_d1, HEX1);
endmodule

module full_adder_4b(x, y, c_in, s);
	input [3:0]x, y;
	input c_in;
	output [4:0]s;
	wire c0, c1, c2;
	full_adder f0(x[0], y[0], c_in, s[0], c0);
	full_adder f1(x[1], y[1], c0, s[1], c1);
	full_adder f2(x[2], y[2], c1, s[2], c2);
	full_adder f3(x[3], y[3], c2, s[3], s[4]);
endmodule

module full_adder(a, b, c_in, sum, c_out);
	input a, b, c_in;
	output sum, c_out;

	assign sum = a^b^c_in;
	assign c_out = (a & c_in) | (b & c_in) | (b & a);
endmodule

module display_d0 (input [3:0]s, output [6:0]disp);
	assign disp[0] = (s[2] & ~s[1] & ~s[0]) | (~s[3] & ~s[2] & ~s[1] & s[0]);
	assign disp[1] = (s[2] & ~s[1] & s[0]) | (s[2] & s[1] & ~s[0]);
	assign disp[2] = (~s[2] & s[1] & ~s[0]);
	assign disp[3] = (s[2] & ~s[1] & ~s[0]) | (~s[2] & ~s[1] & s[0]) | (s[2] & s[1] & s[0]);
	assign disp[4] = s[0] | (s[2] & ~s[1] & ~s[0]);
	assign disp[5] = (~s[3] & ~s[2] & s[1] & ~s[0]) | (~s[3] & ~s[2] & s[0]) | (s[2] & s[1] & s[0]);
	assign disp[6] = (s[2] & s[1] & s[0]) | (~s[3] & ~s[2] & ~s[1]);
endmodule

module comparator(input [3:0]v, output z);
	assign z = (v[3] & v[2]) | (v[3] & v[1]);
endmodule

module get_a(v, carry, a);
	input [3:0]v;
	input carry;
	output [3:0]a;

	assign a[3] = 0;
	assign a[2] = v[2] & v[1];
	assign a[1] = ~v[1];
	assign a[0] = v[0];
endmodule

module get_b(s, b);
	input [3:0]s;
	output [3:0]b;

	assign b[3] = s[1];
	assign b[2] = ~s[1];
	assign b[1] = ~s[1];
	assign b[0] = s[0];
endmodule

module mux4b_2to1(x1, x2, s, f);
	input [3:0]x1, x2;
	input s;
	output [3:0]f;

	assign f[0] = (x1[0] & ~s) | (x2[0] & s);
	assign f[1] = (x1[1] & ~s) | (x2[1] & s);
	assign f[2] = (x1[2] & ~s) | (x2[2] & s);
	assign f[3] = (x1[3] & ~s) | (x2[3] & s);
endmodule
