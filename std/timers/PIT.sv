/*
Provides:
	Programmable Interval Timer (PIT)
Dependencies:
	_prescaler
	tree_decoder
	counter_backward
Parameters:
	CNTR_WORD_WIDTH	- width of input and output words (for reset value)
	PS_WORD_WIDTH	- width of input and output words (prescaler)
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	ae_i			- action enable
	action_i		- action
	value_i			- value for reset value and prescaler
	irq_o			- counter signal
Generation:
	None
Additional comments:
	None
Action table:
	action_i = 0	- set prescaler delay
	action_i = 1	- set counter value
	action_i = 2	- set reset value
	action_i = 3	- set mode
Mod table:
	mode = 0		- count down and stop
	mode = 1		- count down and reset (repeat)
*/
module PIT #(
	parameter PS_WORD_WIDTH,
	parameter CNTR_WORD_WIDTH
) (
	input	wire													clk_i,
	input	wire													arst_i,
	input	wire													ae_i, //action enable
	input	wire	[1:0]											action_i,
	input	wire	[`max(PS_WORD_WIDTH, CNTR_WORD_WIDTH) - 1:0]	value_i,
	output	wire													irq_o
);
reg [CNTR_WORD_WIDTH - 1:0] cntr_reset_value;
reg mode;
wire [CNTR_WORD_WIDTH - 1:0] cntr_value;
wire set_prsclr;
wire set_cntr;
wire set_cntr_reset_value;
wire set_mode;
wire cntr_clock_en;
tree_decoder #(.OUTPUT_WIDTH(4)) action_decoder (
	.enable_i(ae_i),
	.select_i(action_i),
	.data_o({set_mode, set_cntr_reset_value, set_cntr, set_prsclr})
);
_prescaler #(.WORD_WIDTH(PS_WORD_WIDTH)) prsclr (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.we_i(set_prsclr),
	.clk_value_i(value_i[PS_WORD_WIDTH - 1:0]),
	.clk_en_o(cntr_clock_en)
);
counter_backward #(.WORD_WIDTH(CNTR_WORD_WIDTH), .WORD_RESET(0)) cntr (
	.clk_i(clk_i),
	.action_i(~cntr_clock_en | set_cntr | irq_o),
	.arst_i(arst_i),
	.data_i(set_cntr ? value_i[CNTR_WORD_WIDTH - 1:0] : ((irq_o & mode & (cntr_clock_en)) ? cntr_reset_value : cntr_value)),
	.data_o(cntr_value),
	.will_underflow_o(irq_o)
);
always_ff @(posedge arst_i or posedge clk_i) begin
	if (arst_i) begin
		cntr_reset_value <= '0;
		mode <= '0;
	end else begin
		if (set_cntr_reset_value) begin
			cntr_reset_value <= value_i[CNTR_WORD_WIDTH - 1:0];
		end
		if (set_mode) begin
			mode <= value_i[0];
		end
	end
end
endmodule