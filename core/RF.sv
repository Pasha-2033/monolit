`ifndef STD_UTILS
	`include "utils.sv"
`endif
module RF #(
	parameter WORD_WIDTH,
	parameter ADDRESS_WIDTH,
	parameter IP_OFFSET
) (
	input	wire								clk_i,
	input	wire								arst_i,

	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_a_i,	//arithmetic, logic, 2x shift
	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_b_i,	//arithmetic, logic, 2x shift
	input	wire	[1:0][ADDRESS_WIDTH - 1:0]	select_c_i,	//2x shift
	input	wire	[3:0][ADDRESS_WIDTH - 1:0]	select_r_i,	//arithmetic, logic, 2x shift

	input	wire	[ADDRESS_WIDTH - 1:0]		select_ROD_i,	//Read Only Data
	input	wire	[ADDRESS_WIDTH - 1:0]		select_ROA_i,	//Read Only Address

	input	wire	[WORD_WIDTH - 1:0]			main_input_i,	//Core read
	input	wire	[WORD_WIDTH - 1:0]			inst_input_i,	//Instruction immutable

	input	wire	[3:0][WORD_WIDTH - 1:0]		data_i,
	input	wire	[3:0]						enable_writing_i,

	output	wire	[3:0][WORD_WIDTH - 1:0]		a_o,
	output	wire	[3:0][WORD_WIDTH - 1:0]		b_o,
	output	wire	[1:0][WORD_WIDTH - 1:0]		c_o,

	output	wire	[WORD_WIDTH - 1:0]			ROD_o,	//Read Only Data
	output	wire	[WORD_WIDTH - 1:0]			ROA_o	//Read Only Address
);
localparam UNITS = 2 ** ADDRESS_WIDTH;	//how many units can be selected

wire [3:0][UNITS - 3:0] decoded_select;
tree_decoder #(.OUTPUT_WIDTH(UNITS - 2)) tdec [3:0] (
	.enable_i(enable_writing_i),
	.select_i(select_r_i),
	.data_o(decoded_select)
);

reg [UNITS - 3:0][WORD_WIDTH - 1:0] GPR;

wire [UNITS - 3:0] senior_priority = decoded_select[2] | decoded_select[3];
wire [UNITS - 3:0] enable_unit = decoded_select[0] | decoded_select[1] | senior_priority;

wire [1:0][UNITS - 3:0][WORD_WIDTH - 1:0] data_to_unit_mux_layer;
wire [UNITS - 3:0][WORD_WIDTH - 1:0] data_to_unit;

wire [UNITS - 1:0][WORD_WIDTH - 1:0] data_out = {
	inst_input_i,
	main_input_i,
	GPR
};

genvar i;
generate
	for(i = 0; i < 4; ++i) begin : data_out_selection
		assign a_o[i] = data_out[select_a_i[i]];
		assign b_o[i] = data_out[select_b_i[i]];
	end
	for(i = 0; i < UNITS - 2; ++i) begin : data_to_unit_selection
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
assign ROD_o = data_out[select_ROD_i];
assign ROA_o = data_out[select_ROA_i];
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