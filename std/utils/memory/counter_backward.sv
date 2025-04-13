/*
Provides: 
	Counter with builded in subtractor
Dependencies:
	NONE
Parameters:
	WORD_WIDTH	- width of counter value and value for loading
Ports:
	clk_i				- clock
	action_i			- count/load
	arst_i				- asynchronous reset
	data_i				- data for loading
	data_o				- counter value
	will_underflow_o	- shows if next count will be with underflow
Generation:
	NONE
Additional comments:
	Action input doesn`t affect will_underflow output
Action table:
	action_i = 0	- count down
	action_i = 1	- load
*/
module counter_backward #(
	parameter WORD_WIDTH
) (
	input	wire					clk_i,
	input	wire					action_i,
	input	wire					arst_i,

	input	wire [WORD_WIDTH - 1:0]	data_i,
	output	reg  [WORD_WIDTH - 1:0]	data_o,

	output	wire					will_underflow_o
);
wire [WORD_WIDTH - 2:0] load_flow = {load_flow[WORD_WIDTH - 3:0] | data_o[WORD_WIDTH - 2:1], data_o[0]};

assign will_underflow_o = ~|data_o;

always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data_o <= '0;
	end 
	else begin
		data_o <= action_i ? data_i : {data_o[WORD_WIDTH - 1:1] ^ ~load_flow, ~data_o[0]};
	end
end
endmodule