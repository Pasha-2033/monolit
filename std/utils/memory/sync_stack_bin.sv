/*
Provides:
	Synchronous stack with binary controlled output
Dependencies:
	counter
	tree_decoder
Parameters:
	WORD_WIDTH		- width of word to store
	ADDRESS_WIDTH	- width of address
Ports:
	clk_i		- clock
	arst_i		- asynchronous reset
	push_i		- push word to stack
	pop_i		- pop word from stack
	data_i		- data for pushing
	data_o		- data from poping
	point_o		- current counter position
	is_empty_o	- is stack empty?
	is_full_o	- is stack full?
Generation:
	NONE
Additional comments:
	DO NOT CAUSE OVERFLOW/UNDERFLOW!!!
*/
module sync_stack_bin #(
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
wire [LENGTH - 1:0] push_index;
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
tree_decoder #(.OUTPUT_WIDTH(LENGTH)) dec (
	.enable_i('1),
	.select_i(point_o),
	.data_o(push_index)
);
assign data_o = push_i & pop_i ? data_i : data[point_o];
integer i;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
	end else begin
		if (push_i & ~pop_i) begin
			if (push_index[LENGTH - 1]) begin
				data[0] <= data_i;
			end
			for (i = 1; i < LENGTH; ++i) begin
				if (push_index[i - 1]) begin
					data[i] <= data_i;
				end
			end		
		end
	end
end
endmodule