/*
Provides:
	Carry select adder unit
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	c_i		- carry in
	a_i		- A operand
	b_i 	- B operand
	r_o 	- result
	c_o		- carry out
Generation:
	NONE
Additional comments:
	Fully combinational
*/
module _CSA_U #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,

	input	wire [WORD_WIDTH - 1:0]	a_i,
	input	wire [WORD_WIDTH - 1:0]	b_i,
	output	wire [WORD_WIDTH - 1:0]	r_o,

	output	wire 					c_o
);
wire [1:0] pre_c_out;
wire [1:0][WORD_WIDTH - 1:0] pre_r;
assign c_o = pre_c_out[c_i];
assign r_o = pre_r[c_i];

//adders (TODO), RCA_M is temp(?)
RCA_M #(.WORD_WIDTH(WORD_WIDTH)) adders [1:0] (
	.c_i	(2'b10),
	.a_i	({a_i, a_i}),
	.b_i	({b_i, b_i}),
	.r_o	(pre_r),
	.c_o	(pre_c_out)
);
endmodule