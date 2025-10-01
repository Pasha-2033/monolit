module main (
	input wire clk,

	//RF
	input	wire				arst,
	input	wire	[3:0][2:0]	select_a,
	input	wire	[3:0][2:0]	select_b,
	input	wire	[1:0][2:0]	select_c,
	input	wire	[3:0][2:0]	select_r,
	input	wire	[3:0]		enable_writing,

	input	wire	[31:0]		main_input_i,
	input	wire	[31:0]		inst_input_i,

	input	wire	[15:0]		flags_i,
	//ALU
	input	wire	[1:0]		select_flags_i,
	input	wire				cf_i,

	input	wire	[1:0]		AB_op_i,
	input	wire	[1:0]		LB_op_i,
	input	wire	[1:0]		LSB_op_i,
	input	wire	[1:0]		RSB_op_i,

	input	wire	[7:0]		in,
	output	wire	[15:0]		out,

	output	wire	[7:0]		instr_ptr_o,
	output	reg		[31:0]		flags_o
);

fast_comparator #(.WORD_WIDTH(4)) bpu_comparator (
	.a_i(main_input_i),
	.b_i(main_input_i)
	//.below_o(jump_o)
);

wire [3:0][31:0] RF_D_IN;
wire [3:0][31:0] RF_A;
wire [3:0][31:0] RF_B;
wire [1:0][31:0] RF_C;
wire [31:0] RF_F = {
	11'b0,
	ALU_pf_o,
	ALU_sf_o,
	ALU_of_o,
	ALU_zf_o,
	ALU_cf_o,
	flags_i
};
//RF
RF_32x #(.ADDRESS_WIDTH(3)) rf (
	.clk_i(clk),
	.arst_i(arst),
	.select_a_i(select_a),
	.select_b_i(select_b),
	.select_c_i(select_c),
	.select_r_i(select_r),
	.main_input_i(main_input_i),
	.inst_input_i(inst_input_i),
	.flags_i(RF_F),
	.data_i(RF_D_IN),
	.enable_writing_i(enable_writing),
	.a_o(RF_A),
	.b_o(RF_B),
	.c_o(RF_C),
	.instr_ptr_o(instr_ptr_o),
	.flags_o(flags_o)
);

wire ALU_cf_o;
wire ALU_zf_o;
wire ALU_of_o;
wire ALU_sf_o;
wire ALU_pf_o;
//ALU
ALU #(.WORD_WIDTH(32)) alu (
	.select_flags_i(select_flags_i),
	.cf_i(cf_i),
	.cf_o(ALU_cf_o),
	.zf_o(ALU_zf_o),
	.of_o(ALU_of_o),
	.sf_o(ALU_sf_o),
	.pf_o(ALU_pf_o),
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
	.LSB_c_i(RF_C[0][30:0]),
	.LSB_r_o(RF_D_IN[2]),
	//Right shift  block
	.RSB_op_i(RSB_op_i),
	.RSB_a_i(RF_A[3]),
	.RSB_b_i(RF_B[3]),
	.RSB_c_i(RF_C[1][30:0]),
	.RSB_r_o(RF_D_IN[3])
);
//Signed extension
signed_extension #(.IN_WIDTH(8), .OUT_WIDTH(16)) se (
	.in(in),
	.out(out)
);
//
BPU_LVL_1 #(.STEP_NUM(4), .JUMP_AREA(12)) bpu (
	.clk_i(clk),
	.arst_i(arst)

	//input wire conditional_jump_i,	//if jump happend
	//input wire shouldnt_jump_i,


	//output wire jump_o
);
endmodule