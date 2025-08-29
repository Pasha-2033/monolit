module main (
	input wire clk,

	//RF
	input	wire				arst,
	input	wire	[3:0][2:0]	select_a,
	input	wire	[3:0][2:0]	select_b,
	input	wire	[1:0][2:0]	select_c,
	input	wire	[3:0][2:0]	select_r,
	input	wire	[3:0]		enable_writing,
	input	wire	[3:0][7:0]	RF_D_IN,
	output	wire	[3:0][7:0]	RF_A,
	output	wire	[3:0][7:0]	RF_B,
	output	wire	[1:0][7:0]	RF_C,
	//Arithmetic block
	input	wire	[1:0]	ab_op_i,
	input	wire	[7:0]	ab_a_i,
	input	wire	[7:0]	ab_b_i,
	input	wire	[7:0]	ab_not_b_i,
	output	wire	[7:0]	ab_r_o,
	input	wire			ab_cf_i,	//carry flag (int)
	output	wire			ab_cf_o,	//carry flag (out)
	output	wire			ab_zf_o,	//zero flag
	output	wire			ab_of_o,	//overflow flag
	output	wire			ab_pf_o,	//parity flag
	output	wire			ab_sf_o,	//sign flag
	//Logic block
	input	wire	[1:0]	lb_op_i,
	input	wire	[7:0]	lb_a_i,
	input	wire	[7:0]	lb_b_i,
	input	wire	[7:0]	lb_not_b_i,
	output	wire	[7:0]	lb_r_o,
	output	wire			lb_cf_o,	//carry flag (out)
	output	wire			lb_zf_o,	//zero flag
	output	wire			lb_of_o,	//overflow flag
	output	wire			lb_pf_o,	//parity flag
	output	wire			lb_sf_o,		//sign flag
	//Left shift
	input	wire	[1:0]	ls_op_i,
	input	wire	[7:0]	ls_a_i,
	input	wire	[7:0]	ls_b_i,
	input	wire	[7:0]	ls_c_i,
	output	wire	[7:0]	ls_r_o,
	input	wire			ls_cf_i,	//carry flag (in)
	output	wire			ls_cf_o,	//carry flag (out)
	output	wire			ls_zf_o,	//zero flag
	output	wire			ls_of_o,	//overflow flag
	output	wire			ls_pf_o,	//parity flag
	output	wire			ls_sf_o,		//sign flag
	//Right shift
	input	wire	[1:0]	rs_op_i,
	input	wire	[7:0]	rs_a_i,
	input	wire	[7:0]	rs_b_i,
	input	wire	[7:0]	rs_c_i,
	output	wire	[7:0]	rs_r_o,
	input	wire			rs_cf_i,	//carry flag (in)
	output	wire			rs_cf_o,	//carry flag (out)
	output	wire			rs_zf_o,	//zero flag
	output	wire			rs_of_o,	//overflow flag
	output	wire			rs_pf_o,	//parity flag
	output	wire			rs_sf_o		//sign flag
);
//RF
RF #(.WORD_WIDTH(8), .ADDRESS_WIDTH(3), .IP_OFFSET(2)) rf (
	.clk_i(clk),
	.arst_i(arst),
	.select_a_i(select_a),
	.select_b_i(select_b),
	.select_c_i(select_c),
	.select_r_i(select_r),
	.data_i(RF_D_IN),
	.enable_writing_i(enable_writing),
	.a_o(RF_A),
	.b_o(RF_B),
	.c_o(RF_C)
);
//Arithmetic block
arithmetic_block #(.WORD_WIDTH(8)) ab (
	.op_i(ab_op_i),
	.a_i(ab_a_i),
	.b_i(ab_b_i),
	.not_b_i(ab_not_b_i),
	.r_o(ab_r_o),
	.cf_i(ab_cf_i),
	.cf_o(ab_cf_o),
	.zf_o(ab_zf_o),
	.of_o(ab_of_o),
	.pf_o(ab_pf_o),
	.sf_o(ab_sf_o)	
);
//Logic block
logic_block #(.WORD_WIDTH(8)) lb (
	.op_i(lb_op_i),
	.a_i(lb_a_i),
	.b_i(lb_b_i),
	.not_b_i(lb_not_b_i),
	.r_o(lb_r_o),
	.cf_o(lb_cf_o),
	.zf_o(lb_zf_o),
	.of_o(lb_of_o),
	.pf_o(lb_pf_o),
	.sf_o(lb_sf_o)
);
//Left shift
left_shift_block #(.WORD_WIDTH(8)) lsb (
	.op_i(ls_op_i),
	.a_i(ls_a_i),
	.b_i(ls_b_i),
	.c_i(ls_c_i),
	.r_o(ls_r_o),
	.cf_i(ls_cf_i),
	.cf_o(ls_cf_o),
	.zf_o(ls_zf_o),
	.of_o(ls_of_o),
	.pf_o(ls_pf_o),
	.sf_o(ls_sf_o)
);
//Right shift
right_shift_block #(.WORD_WIDTH(8)) rsb (
	.op_i(rs_op_i),
	.a_i(rs_a_i),
	.b_i(rs_b_i),
	.c_i(rs_c_i),
	.r_o(rs_r_o),
	.cf_i(rs_cf_i),
	.cf_o(rs_cf_o),
	.zf_o(rs_zf_o),
	.of_o(rs_of_o),
	.pf_o(rs_pf_o),
	.sf_o(rs_sf_o)
);
endmodule