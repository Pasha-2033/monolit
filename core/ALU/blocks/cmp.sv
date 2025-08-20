`ifndef STD_UTILS
	`include "utils.sv"
`endif



module cmp_block #(
	parameter WORD_WIDTH
) (
	input wire	[1:0]				op_i,
	input wire	[WORD_WIDTH - 1:0]	a_i,
	input wire	[WORD_WIDTH - 1:0]	b_i,
	output wire	[WORD_WIDTH - 1:0]	r_o
);
wire above, below;
fast_comparator #(.WORD_WIDTH(WORD_WIDTH)) fc (
	.a_i(a_i),
	.b_i(b_i),
	.above_o(above),
	.below_o(below)
);
//assign r_o = a_i;
//assign CF_OUT = below & op_i[0];
//assign ZF_OUT = ~(above | below);
endmodule