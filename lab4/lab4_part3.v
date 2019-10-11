module lab4_part3(input [9:0]SW, output LEDR[9:0]);
	wire c0, c1, c2, c3, s0, s1, s2, s3;

	full_adder f0(SW[0], SW[4], SW[8], s0, c0)
	full_adder f1(SW[1], SW[5], c0, s1, c1)
	full_adder f2(SW[2], SW[6], c1, s2, c2)
	full_adder f3(SW[3], SW[7], c2, s3, c3)

	assign LEDR[0] = s0;
	assign LEDR[1] = s1;
	assign LEDR[2] = s2;
	assign LEDR[3] = s3;
	assign LEDR[4] = c3;
endmodule

module full_adder(a, b, c_in, sum, c_out);
	input a, b, c_in;
	output sum, c_out;

	assign sum = a^b^c_in;
	assign c_out = (a & c_in) | (b & c_in) | (b & a);
endmodule
