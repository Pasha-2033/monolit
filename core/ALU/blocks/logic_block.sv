module logic_block #(
	parameter WORD_WIDTH
) (
	//operation
	input	wire	[1:0]				op_i,
	//operands
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,
	input	wire	[WORD_WIDTH - 1:0]	not_b_i,
	//result
	output	wire	[WORD_WIDTH - 1:0]	r_o,
	//flags
	output	wire						cf_o,	//carry flag (out)
	output	wire						zf_o,	//zero flag
	output	wire						of_o,	//overflow flag
	output	wire						pf_o,	//parity flag
	output	wire						sf_o	//sign flag
);
logic_unit #(.WORD_WIDTH(WORD_WIDTH)) unit (
	.op_i(op_i),
	.a_i(a_i),
	.b_i(b_i),
	.not_b_i(not_b_i),
	.r_o(r_o)
);
localparam [0:0] OF = 0;
localparam [0:0] CF = 0;
assign cf_o = CF;
assign zf_o = ~|r_o;
assign of_o = OF;
assign pf_o = r_o[0];
assign sf_o = r_o[WORD_WIDTH - 1];
endmodule