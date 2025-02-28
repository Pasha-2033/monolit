/*
Provides:
	Screen by senior bit in word
Dependencies:
	bit_reverse
	screening_by_junior
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	c_i	- carry in
	in	- word to screen
	out	- screened word
	c_o	- carry out 
Generation:
	NONE
Additional comments:
	Fully combinational
*/
module screening_by_senior #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,
	input	wire [WORD_WIDTH - 1:0]	in,

	output	wire [WORD_WIDTH - 1:0]	out,
	output	wire					c_o
);
wire [WORD_WIDTH - 1:0] reversed_in;
wire [WORD_WIDTH - 1:0] reversed_out;

bit_reverse #(.WORD_WIDTH(WORD_WIDTH)) reverse_in (
	.in		(in),
	.out	(reversed_in)
);
bit_reverse #(.WORD_WIDTH(WORD_WIDTH)) reverse_out (
	.in		(reversed_out),
	.out	(out)
);

screening_by_junior #(.WORD_WIDTH(WORD_WIDTH)) sbj (
	.c_i	(c_i),
	.in		(reversed_in),
	.out	(reversed_out),
	.c_o	(c_o)
);
endmodule