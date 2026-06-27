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
	data_i			- data for loading
	data_o			- counter value
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
	parameter WORD_WIDTH,
	parameter WORD_RESET = 0
) (
	input	wire					clk_i,
	input	wire					action_i,
	input	wire					arst_i,

	input	wire [WORD_WIDTH - 1:0]	data_i,
	output	reg  [WORD_WIDTH - 1:0]	data_o,

	output	wire					will_overflow_o
);
wire [WORD_WIDTH - 1:0] count_flow;
generate
	if (WORD_WIDTH > 1) begin
		assign count_flow = {count_flow[WORD_WIDTH - 2:0] & data_o[WORD_WIDTH - 2:0], data_o[0]};
		assign will_overflow_o = &data_o;
	end else begin
		assign count_flow = ~data_o;
		assign will_overflow_o = data_o;
	end
endgenerate
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data_o <= WORD_RESET[WORD_WIDTH - 1:0];
	end else begin
		if (WORD_WIDTH > 1) begin
			data_o <= action_i ? data_i : {data_o[WORD_WIDTH - 1:1] ^ count_flow[WORD_WIDTH - 1:1], ~data_o[0]};
		end	else begin
			data_o <= action_i ? data_i : count_flow;
		end
	end
end
endmodule