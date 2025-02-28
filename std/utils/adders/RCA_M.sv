/*
Provides:
	Ripple carry adder improved by Manchester carry chain
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	c_i	- carry in
	a_i	- A operand
	b_i - B operand
	r_o - result
	c_o - carry out
Generation:
	Assigns ripple block to another
Additional comments:
	Fully combinational
*/
module RCA_M #(
	parameter WORD_WIDTH
) (
	input	wire					c_i,

	input	wire [WORD_WIDTH - 1:0]	a_i,
	input	wire [WORD_WIDTH - 1:0]	b_i,

	output	wire [WORD_WIDTH - 1:0]	r_o,
	output	wire					c_o
);
// e - per Element
wire [WORD_WIDTH:0]		e_c;
wire [WORD_WIDTH - 1:0]	e_or	= a_i | b_i;
wire [WORD_WIDTH - 1:0]	e_and	= a_i & b_i;
wire [WORD_WIDTH - 1:0]	e_xor	= e_or & ~e_and;

assign r_o		= e_xor ^ e_c[WORD_WIDTH - 1:0];
assign e_c[0]	= c_i;
assign c_o		= e_c[WORD_WIDTH];

genvar i;
generate
	for (i = 0; i < WORD_WIDTH; ++i) begin: RCA_unit
		assign e_c[i + 1] = e_xor[i] ? e_c[i] : e_and[i];
	end
endgenerate
endmodule