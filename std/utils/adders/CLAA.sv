/*
Provides:
	Carry look-ahead adder
Dependencies:
	_LA
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	c_i		- carry in
	a_i		- A operand
	b_i 	- B operand
	r_o 	- result
	pg_o	- propagation group
	gg_o	- generation group
	c_o		- carry out
Generation:
	Assigns adder block to look-ahead
Additional comments:
	Fully combinational
*/
module CLAA #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,

	input	wire [WORD_WIDTH - 1:0]	a_i,
	input	wire [WORD_WIDTH - 1:0]	b_i,
	output	wire [WORD_WIDTH - 1:0]	r_o,

	output	wire					pg_o,
	output	wire					gg_o,

	output	wire					c_o
);
wire [WORD_WIDTH - 1:0] p = a_i | b_i;
wire [WORD_WIDTH - 1:0] g = a_i & b_i;
wire [WORD_WIDTH - 1:0] c;

assign r_o = (p & ~g) ^ c;

//lookahead implementation
_LA #(.CASCADE_SIZE(WORD_WIDTH)) lookahead (
	.c_i	(c_i),
	.p_i	(p),
	.g_i	(g),
	.c_o	({c_o, c}),
	.pg_o	(pg_o),
	.gg_o	(gg_o)
);
endmodule