module part1(SW, HEX0, HEX1);
	input [7:0]SW;
	output [6:0]HEX0, HEX1;
	display D1(SW[3:0], HEX0);
	display D2(SW[7:4], HEX1);
endmodule

module display(input [3:0]s, output [6:0]disp);
	disp[0] = s[3]|s[1];
	disp[1] = s[1]&(s[3]|s[2]);
	disp[2] = s[2];
	disp[3] = s[1]|s[3];
	disp[4] = s[3]|s[1];
	disp[5] = s[2]|s[3];
	disp[6] = ~s[0]&~s[1]&~s[2]&~s[3] | s[3] | s[1]&s[2]&s[3];
endmodule
