module arithmetic_block #(
	parameter WORD_WIDTH
) (
	input wire						cf_i,
	input wire	[1:0]				op_i,
	input wire	[WORD_WIDTH - 1:0]	a_i,
	input wire	[WORD_WIDTH - 1:0]	b_i,
	input wire	[WORD_WIDTH - 1:0]	not_b_i,
	output wire	[WORD_WIDTH - 1:0]	r_o,
	output wire						cf_o
);
//TODO: add adder from utils
wire [WORD_WIDTH - 1:0] pre_adder = op_i[0] ? not_b_i : b_i;
wire [WORD_WIDTH - 1:0] post_adder;
assign {cf_o, post_adder} = a_i + pre_adder + (cf_i & op_i[1]);
assign r_o = op_i[0] ? ~post_adder : post_adder;
endmodule