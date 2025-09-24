`include "RF/RF_32x.SV"
`include "RF/FLAGS.SV"
`include "ALU/ALU.sv"
`include "ALU/blocks/arithmetic_block.sv"
`include "ALU/blocks/logic_block.sv"
`include "ALU/blocks/left_shift_block.sv"
`include "ALU/blocks/right_shift_block.sv"
`include "ALU/units/arithmetic_unit.sv"
`include "ALU/units/logic_unit.sv"
`include "ALU/units/left_shift_unit.sv"
`include "ALU/units/right_shift_unit.sv"
module main;

always #10 clk = ~clk;
//RF
logic				clk = '0;
logic				arst;
logic	[3:0][4:0]	select_a;
logic	[3:0][4:0]	select_b;
logic	[1:0][4:0]	select_c;
logic	[3:0][4:0]	select_r;
logic	[3:0]		enable_writing;

logic	[4:0]		select_ROD_i;
logic	[4:0]		select_ROA_i;

logic	[31:0]		main_input_i;
logic	[31:0]		inst_input_i;

wire	[31:0]		ROD_o;
wire	[31:0]		ROA_o;
//ALU
logic	[1:0]		select_flags_i;
logic				cf_i;
wire				cf_o;
wire				zf_o;
wire				of_o;
wire				sf_o;
wire				pf_o;

logic	[1:0]		AB_op_i;
logic	[1:0]		LB_op_i;
logic	[1:0]		LSB_op_i;
logic	[1:0]		RSB_op_i;


wire [3:0][31:0] RF_D_IN;

wire [3:0][31:0] RF_A;
wire [3:0][31:0] RF_B;
wire [1:0][31:0] RF_C;
//RF
RF_32x #(.ADDRESS_WIDTH(5)) rf (
	.clk_i(clk),
	.arst_i(arst),
	.select_a_i(select_a),
	.select_b_i(select_b),
	.select_c_i(select_c),
	.select_r_i(select_r),
	.main_input_i(main_input_i),
	.inst_input_i(inst_input_i),
	.data_i(RF_D_IN),
	.enable_writing_i(enable_writing),
	.a_o(RF_A),
	.b_o(RF_B),
	.c_o(RF_C)
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
	.LSB_c_i(RF_C[0][30:0]),
	.LSB_r_o(RF_D_IN[2]),
	//Right shift  block
	.RSB_op_i(RSB_op_i),
	.RSB_a_i(RF_A[3]),
	.RSB_b_i(RF_B[3]),
	.RSB_c_i(RF_C[1][30:0]),
	.RSB_r_o(RF_D_IN[3])
);
initial begin
	arst = '1;
	clk = '0;
	select_a[0] = 0;
	select_a[1] = 1;
	select_a[2] = 2;
	select_a[3] = 3;
	#5
	$display("A[0]:%d\tA[1]:%d\tA[2]:%d\tA[3]:%d",
		RF_A[0], RF_A[1], RF_A[2], RF_A[3]
	);
	arst = '0;

	main_input_i = 1;
	inst_input_i = 2;

	AB_op_i = 0;

	select_a[0] = 30;
	
	select_b[0] = 31;

	select_r[0] = 0;

	select_c[0] = select_r[0];

	enable_writing = 4'b0001;
	#20
	$display("C[0]:%d", RF_C[0]);
end
endmodule