/*
Provides:
	Synchronous queue with binary controlled output
Dependencies:
	counter
	tree_decoder
Parameters:
	WORD_WIDTH		- width of word to store
	ADDRESS_WIDTH	- width of address
Ports:
	clk_i		- clock
	arst_i		- asynchronous reset
	push_i		- push word to queue
	pop_i		- pop word from queue
	data_i		- data for pushing
	data_o		- data from poping
	point		- current counter position
	is_empty_o	- is queue empty?
	is_full_o	- is queue full?
Generation:
	NONE
Additional comments:
	DO NOT CAUSE OVERFLOW/UNDERFLOW!!!
*/
module sync_queue_bin #(
	parameter WORD_WIDTH,
	parameter ADDRESS_WIDTH
) (
	input	wire							clk_i,
	input	wire							arst_i,
	input	wire							push_i,
	input	wire							pop_i,
	input	wire	[WORD_WIDTH - 1:0]		data_i,
	output	wire	[WORD_WIDTH - 1:0]		data_o,
	output	wire	[ADDRESS_WIDTH - 1:0]	point_o,
	output	wire							is_empty_o,
	output	wire							is_full_o
);
localparam LENGTH = 2 ** ADDRESS_WIDTH;
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
wire [LENGTH - 1:0][WORD_WIDTH - 1:0] shifted_output;
counter #(.WORD_WIDTH(ADDRESS_WIDTH)) pointer (
	.clk_i(clk_i),
	.count_i(push_i ^ pop_i),
	.load_i(~push_i & pop_i),
	.arst_i(arst_i),
	.data_i('0),
	.data_o(point_o),
	.will_overflow_o(is_full_o),
	.will_underflow_o(is_empty_o)
);
assign shifted_output = {data[LENGTH - 2:0], data[LENGTH - 1]};
//if we will push & pop at the same time with 0 cap - we will get data[LENGTH - 1], which is not initialized
//if we will push & pop at the sane time with !0 cap - we will shift data register and get correct shifted_output[point] result
assign data_o = is_empty_o ? data_i : shifted_output[point_o];
integer i;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
	end else if (push_i) begin
		data <= {data[LENGTH - 2:0], data_i};
	end
end
endmodule