`ifndef STD_UTILS
	`include "utils.sv"
`endif
module arithmetic_unit #(
	parameter WORD_WIDTH
) (
	input	wire						cf_i,
	input	wire	[1:0]				op_i,
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,
	input	wire	[WORD_WIDTH - 1:0]	not_b_i,
	output	wire	[WORD_WIDTH - 1:0]	r_o,
	output	wire						cf_o
);
wire [WORD_WIDTH - 1:0] post_adder;
assign r_o = op_i[0] ? ~post_adder : post_adder;
//TODO: create multi-level CLAA
CLAA #(.WORD_WIDTH(WORD_WIDTH)) claa (
	.c_i(cf_i & op_i[1]), 
	.a_i(a_i), 
	.b_i(op_i[0] ? not_b_i : b_i),
	.r_o(post_adder),
	//ingore technical outupts P & G
	.c_o(cf_o)
);
endmodule