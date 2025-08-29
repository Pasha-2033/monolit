`ifndef STD_UTILS
	`include "utils.sv"
`endif
module left_shift_unit #(
	parameter WORD_WIDTH
) (
	input	wire						cf_i,
	input	wire	[1:0]				op_i,
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,
	input	wire	[WORD_WIDTH - 2:0]	c_i,
	output	wire	[WORD_WIDTH - 1:0]	r_o,
	output	wire						cf_o
);
wire [$clog2(WORD_WIDTH) - 1:0] shift_size = b_i[$clog2(WORD_WIDTH) - 1:0];
polyshift_l #(.WORD_WIDTH(WORD_WIDTH)) psl (
	.c_i(c_i),
	.data_i(a_i),
	.shift_size_i(shift_size),
	.shift_type_i(op_i),
	.data_o(r_o)
);
polyshift_l_cf #(.WORD_WIDTH(WORD_WIDTH)) psl_cf (
	.cf_i(cf_i),
	.shift_size_i(shift_size),
	.data_i(a_i),
	.cf_o(cf_o)
);
endmodule