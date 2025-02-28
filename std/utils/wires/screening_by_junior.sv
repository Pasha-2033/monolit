/*
Provides:
	Screen by junior bit in word
Dependencies:
	NONE
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
module screening_by_junior #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,
	input	wire [WORD_WIDTH - 1:0]	in,

	output	wire [WORD_WIDTH - 1:0]	out,
	output	wire					c_o
);
// e - per Element
wire	[WORD_WIDTH:0]	e_or	= {e_or[WORD_WIDTH - 1:0] | in, c_i};
assign					c_o		= e_or[WORD_WIDTH];
assign					out		= {~e_or[WORD_WIDTH - 1:0] & in};
endmodule