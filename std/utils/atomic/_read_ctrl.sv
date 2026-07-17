/*
Provides:
	async_queue read control block
Dependencies:
	fast_comparator
	RCA_M
	gray_to_bin
	counter_forward
	r2s_sync
Parameters:
	ADDRESS_WIDTH			- how many memory cell will be
	ALMOST_EMPTY_THRESHOLD	- deleay between is_empty_o & almost_empty_o
Ports:
	r_clk_i			- read domain clock
	arst_i			- asynchronous reset
	re_i			- read enable
	is_empty_o		- queue is empty
	almost_empty_o	- queue is almost empty
	w_addr_gray_i	- write address from _write_ctrl
	r_addr_gray_o	- read address to _write_ctrl
	r_addr_bin_o	- read address to RAM
Generation:
	None
Additional comments:
	None
*/
module _read_ctrl #(
    parameter ADDRESS_WIDTH,
	parameter ALMOST_EMPTY_THRESHOLD
)(

	input	wire							r_clk_i,
	input	wire							arst_i,

	input	wire							re_i,	//read enable
	output	wire							is_empty_o,
	output	wire							almost_empty_o,

	//write domain
	input	wire	[ADDRESS_WIDTH:0]		w_addr_gray_i,	// указатель записи из источника
	//read domain
	output	wire	[ADDRESS_WIDTH:0]		r_addr_gray_o,	// указатель чтения из источника
	output	wire	[ADDRESS_WIDTH - 1:0]	r_addr_bin_o	// младшие биты для адресации памяти
);
wire [ADDRESS_WIDTH:0] ptr_bin;
wire [ADDRESS_WIDTH:0] w_addr_gray_sync;
wire [ADDRESS_WIDTH:0] w_addr_bin_sync;
wire [ADDRESS_WIDTH:0] occupied;
wire no_counting;
wire is_empty_above;
wire is_empty_below;
assign no_counting = ~(re_i & ~is_empty_o);
assign r_addr_bin_o = ptr_bin[ADDRESS_WIDTH - 1:0];
assign r_addr_gray_o = `BIN_TO_GRAY(ptr_bin);
assign is_empty_o = ~(is_empty_above | is_empty_below);
fast_comparator #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) is_empty_cmp (
	.a_i(w_addr_bin_sync),
	.b_i(ptr_bin),
	.above_o(is_empty_above),
	.below_o(is_empty_below)
);
generate
	if (ALMOST_EMPTY_THRESHOLD > 0) begin
		wire almost_empty_above;
		wire almost_empty_below;
		fast_comparator #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) almost_empty_cmp (
			.a_i(occupied),
			.b_i(ALMOST_EMPTY_THRESHOLD[ADDRESS_WIDTH:0]),
			.above_o(almost_empty_above),
			.below_o(almost_empty_below)
		);
		RCA_M #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) occupied_adder (
			.c_i('1),
			.a_i(w_addr_bin_sync),
			.b_i(~ptr_bin),
			.r_o(occupied)
		);
		assign almost_empty_o = ~almost_empty_above | almost_empty_below;
	end else begin
		localparam [0:0] EMPTINESS = '0;
		assign almost_empty_o = EMPTINESS;
	end
endgenerate
gray_to_bin #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) r_addr_bin_conv (
	.data_i(w_addr_gray_sync),
	.data_o(w_addr_bin_sync)
);
counter_forward #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) read_ptr (
	.clk_i(r_clk_i),
	.action_i(no_counting),
	.arst_i(arst_i),
	.data_i(ptr_bin),
	.data_o(ptr_bin)
);

r2s_sync #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) syncer  (
	.clk_dst_i(r_clk_i),
	.arst_i(arst_i),
	.sig_i(w_addr_gray_i), 
	.sig_o(w_addr_gray_sync) 
);
endmodule