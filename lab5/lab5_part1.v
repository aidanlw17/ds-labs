module lab5_part1()










module part1(D,Clock,Q1,Q2,Q3);
	input D,Clock;
	output reg Q1,Q2,Q3;

	D_Latch DL(D,Clock,Q1);
	D_Pos_FF D+(D,Clock,Q2);
	D_Neg_FF D-(D,Clock,Q3);

endmodule

module D-Latch(D,clock,Q);
	input D,clock;
	output Q;
	always@(D,clock)
	begin
		if (clock == 1)
			Q=D;
	end
	endmodule

module D_Pos_FF(D,clock,Q);
	input D,clock;
	output reg Q;
	always@(posedge clock)
		Q<=D;
endmodule


module D_Neg_FF(D,clock,Q);
	input D,clock;
	output reg Q;
	always@(negedge clock)
		Q<=D;
endmodule