module lab5_part5(SW, CLOCK_50, HEX0);
	input [9:0] SW, CLOCK_50;
	output [6:0] HEX0;
	wire i;
	wire [15:0] d;

	clock_2 f1(CLOCK_50, i, SW[0]);
	accum f2(d, i, CLOCK_50, 1);
	hex_display f3(d[3:0], HEX0);
endmodule

module display(a, disp);
	input [3:0] a;
	output reg [6:0] disp;

	always @(*)
		case (a)
			4'a0:disp=7'b1000000;
			4'a1:disp=7'b1111001;
			4'a2:disp=7'b0100100; 
			4'a3:disp=7'b0110000;
			4'a4:disp=7'b0011001;
			4'a5:disp=7'b0010010;
			4'a6:disp=7'b0000010;
			4'a7:disp=7'b1111000;
			4'a8:disp=7'b0000000;
			4'a9:disp=7'b0011000;
			4'aA:disp=7'b0001000;
			4'aB:disp=7'b0000011;
			4'aC:disp=7'b1000110;
			4'aD:disp=7'b0100001;
			4'aE:disp=7'b0000110;
			4'aF:disp=7'b0001110;
		endcase
	end
endmodule

module clock_2(clock, e, reset);
	input clock, reset;
	output reg e;
	wire [25:0] w;

	always @(posedge clock or posedge reset)
		begin
			if (reset==1)
				w <= 26'b0;
			else if (w==1)
			begin
				e <= 1'b1;
				w <= 26'b0;
			end
			else
			begin
				e <= 1'b0;
				w <= w + 1;
			end
		end
endmodule

module accum(out, enbl, clk, res);
	input enbl, clk, res;
	output [15:0] t;
	reg [7:0] t;

	always @(posedge clk)
		if (res)
			t <= 8'b0;
		else if (enbl)
			t <= t + 1;

endmodule
