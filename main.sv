module main (
	input wire clk,

	//RF
	input	wire				arst,
	input	wire	[3:0][2:0]	select_a,
	input	wire	[3:0][2:0]	select_b,
	input	wire	[1:0][2:0]	select_c,
	input	wire	[3:0][2:0]	select_r,
	input	wire	[3:0]		enable_writing,

	input	wire	[4:0]		select_ROD_i,
	input	wire	[4:0]		select_ROA_i,

	input	wire	[7:0]		main_input_i,
	input	wire	[7:0]		inst_input_i,

	input	wire	[7:0]		flags_i,

	output	wire	[7:0]		ROD_o,
	output	wire	[7:0]		ROA_o,
	//ALU
	input	wire	[1:0]		select_flags_i,
	input	wire				cf_i,
	output	wire				cf_o,
	output	wire				zf_o,
	output	wire				of_o,
	output	wire				sf_o,
	output	wire				pf_o,

	input	wire	[1:0]		AB_op_i,
	input	wire	[1:0]		LB_op_i,
	input	wire	[1:0]		LSB_op_i,
	input	wire	[1:0]		RSB_op_i,

	input	wire	[7:0]		in,
	output	wire	[15:0]		out,

	output	wire	[7:0]		instr_ptr_o,
	output	reg		[7:0]		flags_o
);
wire [3:0][7:0] RF_D_IN;
wire [3:0][7:0] RF_A;
wire [3:0][7:0] RF_B;
wire [1:0][7:0] RF_C;
//RF
RF #(.WORD_WIDTH(8), .ADDRESS_WIDTH(3), .IP_OFFSET(2)) rf (
	.clk_i(clk),
	.arst_i(arst),
	.select_a_i(select_a),
	.select_b_i(select_b),
	.select_c_i(select_c),
	.select_r_i(select_r),
	.select_ROD_i(select_ROD_i),
	.select_ROA_i(select_ROA_i),
	.main_input_i(main_input_i),
	.inst_input_i(inst_input_i),
	.flags_i(flags_i),
	.data_i(RF_D_IN),
	.enable_writing_i(enable_writing),
	.a_o(RF_A),
	.b_o(RF_B),
	.c_o(RF_C),
	.ROD_o(ROD_o),
	.ROA_o(ROA_o),
	.instr_ptr_o(instr_ptr_o),
	.flags_o(flags_o)
);
//ALU
ALU #(.WORD_WIDTH(32)) alu (
	.select_flags_i(select_flags_i),
	.cf_i(cf_i),
	.cf_o(cf_o),
	.zf_o(zf_o),
	.of_o(of_o),
	.sf_o(sf_o),
	.pf_o(pf_o),
	//Arithmetic block
	.AB_op_i(AB_op_i),
	.AB_a_i(RF_A[0]),
	.AB_b_i(RF_B[0]),
	.AB_r_o(RF_D_IN[0]),
	//Logic block
	.LB_op_i(LB_op_i),
	.LB_a_i(RF_A[1]),
	.LB_b_i(RF_B[1]),
	.LB_r_o(RF_D_IN[1]),
	//Left shift block
	.LSB_op_i(LSB_op_i),
	.LSB_a_i(RF_A[2]),
	.LSB_b_i(RF_B[2]),
	.LSB_c_i(RF_C[0][6:0]),
	.LSB_r_o(RF_D_IN[2]),
	//Right shift  block
	.RSB_op_i(RSB_op_i),
	.RSB_a_i(RF_A[3]),
	.RSB_b_i(RF_B[3]),
	.RSB_c_i(RF_C[1][6:0]),
	.RSB_r_o(RF_D_IN[3])
);
//Signed extension
signed_extension #(.IN_WIDTH(8), .OUT_WIDTH(16)) se (
	.in(in),
	.out(out)
);
endmodule