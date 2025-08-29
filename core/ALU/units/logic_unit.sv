module logic_unit #(
	parameter WORD_WIDTH
) (
	input	wire	[1:0]				op_i,
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,
	input	wire	[WORD_WIDTH - 1:0]	not_b_i,
	output	wire	[WORD_WIDTH - 1:0]	r_o
);
wire [WORD_WIDTH - 1:0] _and = a_i & b_i;
wire [WORD_WIDTH - 1:0] _or = a_i | b_i;
wire [WORD_WIDTH - 1:0] _xor = _or & ~_and;
wire [3:0][WORD_WIDTH - 1:0] merger = {_xor, _or, _and, not_b_i};
assign r_o = merger[op_i];
endmodule