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
	d_i				- data for loading
	d_o				- counter value
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
	parameter WORD_WIDTH
) (
	input	wire					clk_i,
	input	wire					count_i,
	input	wire					load_i,
	input	wire					arst_i,

	input	wire [WORD_WIDTH - 1:0]	d_i,
	output	reg  [WORD_WIDTH - 1:0]	d_o,

	output	wire					will_overflow_o
);
wire [WORD_WIDTH - 1:0] load_flow	= {load_flow[WORD_WIDTH - 2:0] & ~d_o[WORD_WIDTH - 2:0], count_i & load_i};
wire [WORD_WIDTH - 1:0] count_flow	= {count_flow[WORD_WIDTH - 2:0] & d_o[WORD_WIDTH - 2:0], ~load_flow[0]};

assign will_overflow_o = &(load_flow[0] ? ~d_o : d_o);

always @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		d_o <= '0;
	end
	else if (count_i | load_i) begin
		d_o <= ~count_i & load_i ? d_i : {d_o[WORD_WIDTH - 1:1] ^ (count_flow[WORD_WIDTH - 1:1] | load_flow[WORD_WIDTH - 1:1]), ~d_o[0]};
	end
end
endmodule