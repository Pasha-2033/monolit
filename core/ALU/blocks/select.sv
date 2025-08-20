module select_block #(
	parameter WORD_WIDTH
) (
	input wire	[1:0]				op_i,
	input wire	[WORD_WIDTH - 1:0]	a_i,
	input wire	[WORD_WIDTH - 1:0]	b_i,
	input wire	[WORD_WIDTH - 1:0]	c_i,
	input wire	[WORD_WIDTH - 1:0]	d_i,
	output wire	[WORD_WIDTH - 1:0]	r_o
);
wire [3:0][WORD_WIDTH - 1:0] merger = {d_i, c_i, b_i, a_i};
assign r_o = merger[op_i];
endmodule