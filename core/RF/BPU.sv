module BPU_LVL_1 #(
	parameter STEP_NUM,
	parameter [STEP_NUM - 1:0] JUMP_AREA
) (
	input wire clk_i,
	input wire arst_i,

	input wire conditional_jump_i,	//if jump happend
	input wire shouldnt_jump_i,

	output wire jump_o,

	output wire [STEP_NUM - 1:0] bpu_counter_value	//for tests
);
//wire [STEP_NUM - 1:0] bpu_counter_value;
wire bpu_counter_overflow;
wire enable_load = conditional_jump_i & shouldnt_jump_i;
wire bpu_counter_value_non_zero = |bpu_counter_value;
wire [2:0] count_cases = {
	conditional_jump_i & enable_load & bpu_counter_overflow,
	conditional_jump_i & bpu_counter_value_non_zero & ~bpu_counter_overflow,
	conditional_jump_i & ~enable_load & ~bpu_counter_overflow
};
wire load = enable_load & bpu_counter_value_non_zero;
counter #(.WORD_WIDTH(STEP_NUM)) bpu_counter (
	.clk_i(clk_i),
	.count_i(|count_cases),
	.load_i(load),

	.arst_i(arst_i),

	.data_i(bpu_counter_value),
	.data_o(bpu_counter_value),

	.will_overflow_o(bpu_counter_overflow)
);
wire compared_area;
fast_comparator #(.WORD_WIDTH(STEP_NUM)) bpu_comparator (
	.a_i(JUMP_AREA),
	.b_i(bpu_counter_value),
	.below_o(jump_o)
);
endmodule