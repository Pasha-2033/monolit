/*
Provides:
	Clock Domain Crossing Handshake
Dependencies:
	dual_port_memory
	_write_ctrl
	_read_ctrl
Parameters:
	WORD_WIDTH				- width of word to store
	ADDRESS_WIDTH			- how many memory cell will be
	ALMOST_FULL_THRESHOLD	- deleay between is_full_o & almost_full_o
	ALMOST_EMPTY_THRESHOLD	- deleay between is_empty_o & almost_empty_o
Ports:
	w_clk_i			- write domain clock
	r_clk_i			- read domain clock
	arst_i			- asynchronous reset
	we_i			- write enable
	re_i			- read enable
	data_i			- data to queue
	data_o			- data from queue
	is_full_o		- queue is full
	almost_full_o	- queue is almost full
	is_empty_o		- queue is empty
	almost_empty_o	- queue is almost empty
Generation:
	None
Additional comments:
	you can mask almost_full_o by almost_full_o & ~is_full_o
	you can mask almost_empty_o by almost_empty_o & ~is_empty_o
*/
module async_queue #(
	parameter WORD_WIDTH,
	parameter ADDRESS_WIDTH,
	parameter ALMOST_FULL_THRESHOLD,
	parameter ALMOST_EMPTY_THRESHOLD
) (
	input	wire							w_clk_i,
	input	wire							r_clk_i,
	input	wire							arst_i,

	input	wire							we_i,
	input	wire							re_i,

	input	wire	[WORD_WIDTH - 1:0]		data_i,
	output	wire	[WORD_WIDTH - 1:0]		data_o,

	output	wire							is_full_o,
	output	wire							almost_full_o,
	output	wire							is_empty_o,
	output	wire							almost_empty_o
);
wire [ADDRESS_WIDTH - 1:0] read_index;
wire [ADDRESS_WIDTH - 1:0] write_index;
wire [ADDRESS_WIDTH:0] r_addr_gray;
wire [ADDRESS_WIDTH:0] w_addr_gray;
dual_port_memory #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH)) mem (
	.clk_i(w_clk_i),
	.arst_i(arst_i),
	.we_i(we_i & ~is_full_o),
	.addr_read_i(read_index),
	.addr_write_i(write_index),
	.data_i(data_i),
	.data_o(data_o)
);
_write_ctrl #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)) write_controller (
	.w_clk_i(w_clk_i),
	.arst_i(arst_i),

	.we_i(we_i),
	.is_full_o(is_full_o),
	.almost_full_o(almost_full_o),
	.w_addr_bin_o(write_index),
	.w_addr_gray_o(w_addr_gray),

	.r_addr_gray_i(r_addr_gray)
);
_read_ctrl #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)) read_controller (
	.r_clk_i(r_clk_i),
	.arst_i(arst_i),

	.re_i(re_i),
	.is_empty_o(is_empty_o),
	.almost_empty_o(almost_empty_o),

	.w_addr_gray_i(w_addr_gray),

	.r_addr_gray_o(r_addr_gray),
	.r_addr_bin_o(read_index)
);
endmodule