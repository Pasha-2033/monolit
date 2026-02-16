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
module ELU (
	input	wire	[3:0][1:0]	op_i,
	input	wire	[3:0][7:0]	a_i,
	input	wire	[3:0][7:0]	b_i,
	input	wire	[3:0][7:0]	not_b_i,
	output	wire	[3:0][7:0]	r_o
);
wire [3:0][7:0] _and;
wire [3:0][7:0] _or;
wire [3:0][7:0] _xor;
wire [3:0][3:0][7:0] merger;
integer i;
always_comb begin
	_and = a_i ^ b_i;
	_or = a_i | b_i;
	_xor = _or & ~_and;
	for (i = 0; i < 4; ++i) begin : logic_subunit
		merger[i] = {_xor[i], _or[i], _and[i], not_b_i[i]};
		r_o[i] = merger[i][op_i[i]];
	end
end
endmodule