/*
Provides:
	Counter with builded in adder and subtractor
Dependencies:
	NONE
Parameters:
	WORD_WIDTH	- width of counter value and value for loading
Ports:
	clk_i			- clock
	count			- enable counting
	load			- enable loading
	arst_i			- asynchronous reset
	data_i			- data for loading
	data_o			- counter value
	will_overflow_o	- shows if next count will be with overflow
Generation:
	NONE
Additional comments:
	Count and load inputs immediatly affect will_overflow output
Count and load table:
	count_i = 0 & load_i = 0 - do nothing
	count_i = 0 & load_i = 1 - load
	count_i = 1 & load_i = 0 - count up
	count_i = 1 & load_i = 1 - count down
*/
module counter #(
	parameter WORD_WIDTH,
	parameter WORD_RESET = 0
) (
	input	wire					clk_i,
	input	wire					count_i,
	input	wire					load_i,
	input	wire					arst_i,

	input	wire [WORD_WIDTH - 1:0]	data_i,
	output	reg  [WORD_WIDTH - 1:0]	data_o,

	output	wire					will_overflow_o,
	output	wire					will_underflow_o
);
wire [WORD_WIDTH - 1:0] load_flow;
wire [WORD_WIDTH - 1:0] count_flow;
generate
	if (WORD_WIDTH > 1) begin
		assign load_flow	= {load_flow[WORD_WIDTH - 2:0] & ~data_o[WORD_WIDTH - 2:0], count_i & load_i};
		assign count_flow	= {count_flow[WORD_WIDTH - 2:0] & data_o[WORD_WIDTH - 2:0], ~load_flow[0]};
		assign will_overflow_o = &data_o;
		assign will_underflow_o = ~|data_o;
	end else begin
		assign load_flow	= count_i & load_i;
		assign count_flow	= ~data_o;
		assign will_overflow_o = data_o;
		assign will_underflow_o = count_flow;
	end
endgenerate
always @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data_o <= WORD_RESET[WORD_WIDTH - 1:0];
	end else begin
		if (WORD_WIDTH > 1) begin
			if (count_i | load_i) begin
				data_o <= ~count_i & load_i ? data_i : {data_o[WORD_WIDTH - 1:1] ^ (count_flow[WORD_WIDTH - 1:1] | load_flow[WORD_WIDTH - 1:1]), ~data_o[0]};
			end
		end else begin
			data_o <= ~count_i & load_i ? data_i : count_flow;
		end
	end
end
endmodule