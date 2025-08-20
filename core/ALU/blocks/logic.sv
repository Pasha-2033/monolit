module logic_block #(
	parameter word_width
) (
	input wire	[1:0]				op_i,
	input wire	[word_width - 1:0]	a_i,
	input wire	[word_width - 1:0]	b_i,
	input wire	[word_width - 1:0]	not_b_i,
	output wire	[word_width - 1:0]	r_o
);
wire [word_width - 1:0] and = a_i & b_i;
wire [word_width - 1:0] or = a_i | b_i;
wire [word_width - 1:0] xor = or & ~and;
wire [3:0][word_width - 1:0] merger = {xor, or, and, not_b_i};
assign r_o = merger[op_i];
endmodule