`include "utils.sv"
`include "RF.sv"
`timescale 1ps/1ps
module RF_tb;
localparam ADDRESS_WIDTH = 5;
localparam WORD_WIDTH = 32;
enum {SELECT_0, SELECT_1, SELECT_2, SELECT_3} select_unit;
logic								clock = '0;
logic								arst = '0;
logic	[3:0][ADDRESS_WIDTH - 1:0]	select_a;
logic	[3:0][ADDRESS_WIDTH - 1:0]	select_b;
logic	[1:0][ADDRESS_WIDTH - 1:0]	select_c;
logic	[3:0][ADDRESS_WIDTH - 1:0]	select_r;
logic	[3:0][WORD_WIDTH - 1:0]		data_to;
wire	[3:0][WORD_WIDTH - 1:0]		data_a_from;
wire	[3:0][WORD_WIDTH - 1:0]		data_b_from;
wire	[1:0][WORD_WIDTH - 2:0]		data_c_from;
logic	[3:0]						en_writing = '0;
always #10 clock = ~clock;
RF #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .IP_OFFSET(2)) rf (
	.clk_i(clock),
	.arst_i(arst),

	.select_a_i(select_a),	//arithmetic, logic, 2x shift
	.select_b_i(select_b),	//arithmetic, logic, 2x shift
	.select_c_i(select_c),	//2x shift
	.select_r_i(select_r),	//arithmetic, logic, 2x shift

	.data_i(data_to),
	.enable_writing_i(en_writing),

	.a_o(data_a_from),
	.b_o(data_b_from),
	.c_o(data_c_from)
);
initial begin
	arst = '1;
	select_a[0] = 0;
	select_a[1] = 1;
	select_a[2] = 2;
	select_a[3] = 3;
	#5
	$display("A[0]: %d\tA[1]: %d\tA[2]: %d\tA[3]: %d", data_a_from[0], data_a_from[1], data_a_from[2], data_a_from[3]);
	arst = '0;
	en_writing = '1;
	data_to[0] = 0;
	data_to[1] = 1;
	data_to[2] = 2;
	data_to[3] = 3;
	select_r[0] = 0;
	select_r[1] = 1;
	select_r[2] = 2;
	select_r[3] = 3;
	#20
	$display("A[0]: %d\tA[1]: %d\tA[2]: %d\tA[3]: %d", data_a_from[0], data_a_from[1], data_a_from[2], data_a_from[3]);
	en_writing = 4'b0001;
	data_to[0] = 4;
	#20
	$display("A[0]: %d\tA[1]: %d\tA[2]: %d\tA[3]: %d", data_a_from[0], data_a_from[1], data_a_from[2], data_a_from[3]);
end
endmodule