/*
Provides:
	All left shifts
Dependencies:
	NONE
Parameters:
	WORD_WIDTH	- width of operand and result
Ports:
	c_i				- placing bits (for DOUBLE_PRECISION)
	d_i				- word to shift
	shift_size_i	- number of bits to shift
	shift_type_i	- type of shift (see SHIFT_TYPE)
	d_o				- shifted word
Generation:
	scheme contains mode multiplexer and shift multiplexer
	first one is placing bits selection (according to shift_type_i)
	second one is selection of shift size (all shifted words are generated and used for selection)
Additional comments:
	Fully combinational
	Combined barrel shift
*/
module polyshift_l #(
	parameter WORD_WIDTH
) (
	input	wire	[WORD_WIDTH - 2:0]			c_i,
	input	wire	[WORD_WIDTH - 1:0]			d_i,
	input	wire	[$clog2(WORD_WIDTH) - 1:0] 	shift_size_i,
	input	wire	[1:0]						shift_type_i,

	output	wire	[WORD_WIDTH - 1:0]			d_o
);
wire [3:0][WORD_WIDTH - 2:0] shift_args = {
	d_i[WORD_WIDTH - 1:1],		//CYCLIC,
	c_i,						//DOUBLE_PRECISION
	{WORD_WIDTH - 1{1'b0}},		//ARITHMETIC (may be put '1??? because it`s looks like LOGIC)
	{WORD_WIDTH - 1{1'b0}}		//LOGIC
};

wire [WORD_WIDTH - 2:0] shift_arg = shift_args[shift_type_i];
wire [WORD_WIDTH - 1:0][WORD_WIDTH - 1:0] shift_input;
assign shift_input[0] = d_i;
assign d_o = shift_input[shift_size_i];

genvar i;
generate
	for(i = 1; i < WORD_WIDTH; ++i) begin: input_generation
		assign shift_input[i] = {d_i[WORD_WIDTH - i - 1:0], shift_arg[WORD_WIDTH - 2:WORD_WIDTH - i - 1]};
	end
endgenerate
endmodule