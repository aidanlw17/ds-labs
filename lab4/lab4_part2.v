module lab4_part2(SW, HEX0, HEX1);
	input [3:0]SW;
	output [6:0]HEX0, HEX1;

	wire z;
	wire [3:0] A, d0_in;

	comparator C(SW, z);
	get_a get(SW, A);

	mux4b_2to1 mux(SW, A, z, d0_in);

	display_d0 d0(d0_in, HEX0);
	display_d1 d1(z, HEX1);

endmodule

module display_d0(input [3:0]s, output [6:0]disp);
	assign disp[0] = (s[2] & ~s[1] & ~s[0]) | (~s[3] & ~s[2] & ~s[1] & s[0]);
	assign disp[1] = (s[2] & ~s[1] & s[0]) | (s[2] & s[1] & ~s[0]);
	assign disp[2] = (~s[2] & s[1] & ~s[0]);
	assign disp[3] = (s[2] & ~s[1] & ~s[0]) | (~s[2] & ~s[1] & s[0]) | (s[2] & s[1] & s[0]);
	assign disp[4] = s[0] | (s[2] & ~s[1] & ~s[0]);
	assign disp[5] = (~s[3] & ~s[2] & s[1] & ~s[0]) | (~s[3] & ~s[2] & s[0]) | (s[2] & s[1] & s[0]);
	assign disp[6] = (s[2] & s[1] & s[0]) | (~s[3] & ~s[2] & ~s[1]);
endmodule

module comparator(input [3:0]v, output z);
	assign z = (v[3] & v[2]) | (v[3] & ~v[2] & v[1]);
endmodule

module display_d1(input z, output [6:0]disp);
	assign disp[0] = z;
	assign disp[1] = 0;
	assign disp[2] = 0;
	assign disp[3] = z;
	assign disp[4] = z;
	assign disp[5] = z;
	assign disp[6] = 0;
endmodule

module get_a(input [3:0]v, output [3:0]a);
	assign a[3] = 0;
	assign a[2] = v[2] & v[1];
	assign a[1] = ~v[1];
	assign a[0] = v[0];
endmodule

module mux4b_2to1(x1, x2, s, f)
	input [3:0]x1, x2;
	input s;
	output [3:0]f;

	assign f[0] = (x1[0] & ~s) | (x2[0] & s);
	assign f[1] = (x1[1] & ~s) | (x2[1] & s);
	assign f[2] = (x1[2] & ~s) | (x2[2] & s);
	assign f[3] = (x1[3] & ~s) | (x2[3] & s);
endmodule
