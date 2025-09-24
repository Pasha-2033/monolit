`ifndef STD_UTILS
	`include "utils.sv"
`endif
//Written simple, but will cause some warnings
module RF_32x #(
	parameter ADDRESS_WIDTH	//MUST BE 3+, OTHERWISE tdec WILL BE INCORRECT!
) (
	input	wire								clk_i,
	input	wire								arst_i,

	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_a_i,	//arithmetic, logic, 2x shift
	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_b_i,	//arithmetic, logic, 2x shift
	input	wire	[1:0][ADDRESS_WIDTH - 1:0]	select_c_i,	//2x shift
	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_r_i,	//arithmetic, logic, 2x shift

	input	wire	[31:0]						main_input_i,	//Core read
	input	wire	[31:0]						inst_input_i,	//Instruction immutable
	input	wire	[31:0]						flags_i,

	input	wire	[3:0][31:0]					data_i,
	input	wire	[3:0]						enable_writing_i,

	output	wire	[3:0][31:0]					a_o,
	output	wire	[3:0][31:0]					b_o,
	output	wire	[1:0][31:0]					c_o,

	output	wire	[31:0]						instr_ptr_o,
	output	wire	[31:0]						flags_o
);
localparam UNITS = 2 ** ADDRESS_WIDTH;	//how many units can be selected

wire [3:0][UNITS - 1:0] decoded_select;
tree_decoder #(.OUTPUT_WIDTH(UNITS)) tdec [3:0] (
	.enable_i(enable_writing_i),
	.select_i(select_r_i),
	.data_o(decoded_select)
);

reg [UNITS - 1:4][31:0] GPR;
counter_forward #(.WORD_WIDTH(32)) IP (
	.clk_i(clk_i),
	.action_i(enable_unit[3]),
	.arst_i(arst_i),
	.data_i(data_to_unit[3]),
	.data_o(instr_ptr_o)
	//will_overflow_o (ignore, may be used later)
);
FLAGS flags (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.to_kernel(GPR[4][0]),
	.flags_i(flags_i),
	.flags_o(flags_o)
);

wire [UNITS - 1:3] senior_priority = decoded_select[2] | decoded_select[3];					//will truncate, it`s ok
wire [UNITS - 1:3] enable_unit = decoded_select[0] | decoded_select[1] | senior_priority;	//will truncate, it`s ok

wire [1:0][UNITS - 1:3][31:0] data_to_unit_mux_layer;
wire [UNITS - 1:3][31:0] data_to_unit;

wire [UNITS - 1:0][31:0] data_out = {
	GPR,
	instr_ptr_o,
	flags_o,	//здесь проблема, на Wх ожидается Wх флаг, а выдается стабильно 32
	inst_input_i,
	main_input_i
};

genvar i;
generate
	for(i = 0; i < 4; ++i) begin : data_out_selection
		assign a_o[i] = data_out[select_a_i[i]];
		assign b_o[i] = data_out[select_b_i[i]];
	end
	for(i = 3; i < UNITS; ++i) begin : data_to_unit_selection
		assign data_to_unit_mux_layer[0][i] = decoded_select[1][i] ? data_i[1] : data_i[0];
		assign data_to_unit_mux_layer[1][i] = decoded_select[3][i] ? data_i[3] : data_i[2];
		//Quartus allows line below, but Icarus can`t read this rvalue:
		//assign data_to_unit[i] = data_to_unit_mux_layer[senior_priority[i]][i];
		assign data_to_unit[i] = senior_priority[i] ? data_to_unit_mux_layer[1][i] : data_to_unit_mux_layer[0][i];
	end
endgenerate
assign c_o = {
	data_out[select_c_i[1]],
	data_out[select_c_i[0]]
};
integer j;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		GPR <= '0;
	end else begin
		for (j = $low(GPR); j < $high(GPR) + 1; ++j) begin : GPR_set
			if (enable_unit[j]) begin
				GPR[j] <= data_to_unit[j];
			end
		end
	end
end
endmodule