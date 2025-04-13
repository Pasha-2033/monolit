/*
Provides:
	Screen by junior bit in word
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	c_i		- carry in
	data_i	- word to screen
	data_o	- screened word
	c_o		- carry out 
Generation:
	NONE
Additional comments:
	Fully combinational
*/
module screening_by_junior #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,
	input	wire [WORD_WIDTH - 1:0]	data_i,

	output	wire [WORD_WIDTH - 1:0]	data_o,
	output	wire					c_o
);
// e - per Element
wire	[WORD_WIDTH:0]	e_or	= {e_or[WORD_WIDTH - 1:0] | data_i, c_i};
assign					c_o		= e_or[WORD_WIDTH];
assign					data_o	= {~e_or[WORD_WIDTH - 1:0] & data_i};
endmodule