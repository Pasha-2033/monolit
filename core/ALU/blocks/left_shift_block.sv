module left_shift_block #(
	parameter WORD_WIDTH
) (
	//operation
	input	wire	[1:0]				op_i,
	//operands
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,
	input	wire	[WORD_WIDTH - 1:0]	c_i,
	//result
	output	wire	[WORD_WIDTH - 1:0]	r_o,
	//flags
	input	wire						cf_i,	//carry flag (in)
	output	wire						cf_o,	//carry flag (out)
	output	wire						zf_o,	//zero flag
	output	wire						of_o,	//overflow flag
	output	wire						pf_o,	//parity flag
	output	wire						sf_o	//sign flag
);
left_shift_unit #(.WORD_WIDTH(WORD_WIDTH)) unit (
	.cf_i(cf_i),
	.op_i(op_i),
	.a_i(a_i),
	.b_i(b_i),
	.c_i(c_i),
	.r_o(r_o),
	.cf_o(cf_o)
);
assign zf_o = ~|r_o;
assign pf_o = r_o[0];
assign sf_o = r_o[WORD_WIDTH - 1];
assign of_o = sf_o ^ a_i[WORD_WIDTH - 1];
endmodule