/*
Provides:
	Prescaler (timer reductor)
Dependencies:
	counter_backward
Parameters:
	WORD_WIDTH		- width of input and output words
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	we_i			- write enable
	clk_value_i		- clock delay (for writing)
	clk_en_o		- enable timer clock
Generation:
	None
Additional comments:
	None
*/
module _prescaler #(
	parameter WORD_WIDTH
) (
	input	wire						clk_i,
	input	wire						arst_i,
	input	wire						we_i,
	input	wire	[WORD_WIDTH - 1:0]	clk_value_i,
	output	wire						clk_en_o
);
reg [WORD_WIDTH - 1:0] value;
counter_backward #(.WORD_WIDTH(WORD_WIDTH), .WORD_RESET(0)) cnt (
	.clk_i(clk_i),
	.action_i(clk_en_o | we_i),
	.arst_i(arst_i),
	.data_i(value),
	.will_underflow_o(clk_en_o)
);
always_ff @(posedge arst_i or posedge clk_i) begin
	if (arst_i) begin
		value <= '0;
	end else if(we_i) begin
		value <= clk_value_i;
	end
end
endmodule