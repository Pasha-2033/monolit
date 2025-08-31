module ALU #(
	parameter WORD_WIDTH
) (
	//Flags
	input	wire	[1:0]				select_flags_i,
	input	wire						cf_i,
	output	wire						cf_o,
	output	wire						zf_o,
	output	wire						of_o,
	output	wire						sf_o,
	output	wire						pf_o,
	//Arithmetic block
	input	wire	[1:0]				AB_op_i,
	input	wire	[WORD_WIDTH - 1:0]	AB_a_i,
	input	wire	[WORD_WIDTH - 1:0]	AB_b_i,
	output	wire	[WORD_WIDTH - 1:0]	AB_r_o,
	//Logic block
	input	wire	[1:0]				LB_op_i,
	input	wire	[WORD_WIDTH - 1:0]	LB_a_i,
	input	wire	[WORD_WIDTH - 1:0]	LB_b_i,
	output	wire	[WORD_WIDTH - 1:0]	LB_r_o,
	//Left shift block
	input	wire	[1:0]				LSB_op_i,
	input	wire	[WORD_WIDTH - 1:0]	LSB_a_i,
	input	wire	[WORD_WIDTH - 1:0]	LSB_b_i,
	input	wire	[WORD_WIDTH - 2:0]	LSB_c_i,
	output	wire	[WORD_WIDTH - 1:0]	LSB_r_o,
	//Right shift  block
	input	wire	[1:0]				RSB_op_i,
	input	wire	[WORD_WIDTH - 1:0]	RSB_a_i,
	input	wire	[WORD_WIDTH - 1:0]	RSB_b_i,
	input	wire	[WORD_WIDTH - 2:0]	RSB_c_i,
	output	wire	[WORD_WIDTH - 1:0]	RSB_r_o
);
wire [3:0] local_cf;
wire [3:0] local_zf;
wire [3:0] local_of;
wire [3:0] local_pf;
wire [3:0] local_sf;
assign cf_o = local_cf[select_flags_i];
assign zf_o = local_zf[select_flags_i];
assign of_o = local_of[select_flags_i];
assign pf_o = local_pf[select_flags_i];
assign sf_o = local_sf[select_flags_i];
//Arithmetic block
arithmetic_block #(.WORD_WIDTH(WORD_WIDTH)) ab (
	.op_i(AB_op_i),
	.a_i(AB_a_i),
	.b_i(AB_b_i),
	.not_b_i(~AB_b_i),
	.r_o(AB_r_o),
	.cf_i(cf_i),
	.cf_o(local_cf[0]),
	.zf_o(local_zf[0]),
	.of_o(local_of[0]),
	.pf_o(local_pf[0]),
	.sf_o(local_sf[0])	
);
//Logic block
logic_block #(.WORD_WIDTH(WORD_WIDTH)) lb (
	.op_i(LB_op_i),
	.a_i(LB_a_i),
	.b_i(LB_b_i),
	.not_b_i(~LB_b_i),
	.r_o(LB_r_o),
	.cf_o(local_cf[1]),
	.zf_o(local_zf[1]),
	.of_o(local_of[1]),
	.pf_o(local_pf[1]),
	.sf_o(local_sf[1])
);
//Left shift
left_shift_block #(.WORD_WIDTH(WORD_WIDTH)) lsb (
	.op_i(LSB_op_i),
	.a_i(LSB_a_i),
	.b_i(LSB_b_i),
	.c_i(LSB_c_i),
	.r_o(LSB_r_o),
	.cf_i(cf_i),
	.cf_o(local_cf[2]),
	.zf_o(local_zf[2]),
	.of_o(local_of[2]),
	.pf_o(local_pf[2]),
	.sf_o(local_sf[2])
);
//Right shift
right_shift_block #(.WORD_WIDTH(WORD_WIDTH)) rsb (
	.op_i(RSB_op_i),
	.a_i(RSB_a_i),
	.b_i(RSB_b_i),
	.c_i(RSB_c_i),
	.r_o(RSB_r_o),
	.cf_i(cf_i),
	.cf_o(local_cf[3]),
	.zf_o(local_zf[3]),
	.of_o(local_of[3]),
	.pf_o(local_pf[3]),
	.sf_o(local_sf[3])
);
endmodule