/*
Provides: 
	Counter with builded in adder.
Dependencies:
	NONE
Parameters:
	WORD_WIDTH	- width of counter value and value for loading
Ports:
	clk_i			- clock
	action_i		- count/load
	arst_i			- asynchronous reset
	d_i				- data for loading
	d_o				- counter value
	will_overflow_o	- shows if next count will be with overflow
Generation:
	NONE
Additional comments:
	Action input doesn`t affect will_overflow output
Action table:
	action_i = 0	- count up
	action_i = 1	- load
*/
module counter_forward #(
	parameter WORD_WIDTH
) (
	input	wire					clk_i,
	input	wire					action_i,
	input	wire					arst_i,

	input	wire [WORD_WIDTH - 1:0]	d_i,
	output	reg  [WORD_WIDTH - 1:0]	d_o,

	output	wire					will_overflow_o
);
wire [WORD_WIDTH - 2:0] count_flow = {count_flow[WORD_WIDTH - 3:0] & d_o[WORD_WIDTH - 2:1], d_o[0]};

assign will_overflow_o = &d_o;

always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		d_o <= '0;
	end 
	else begin
		d_o <= action_i ? d_i : {d_o[WORD_WIDTH - 1:1] ^ count_flow, ~d_o[0]};
	end
end
endmodule