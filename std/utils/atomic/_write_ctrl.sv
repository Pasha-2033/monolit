/*
Provides:
	async_queue write control block
Dependencies:
	fast_comparator
	RCA_M
	gray_to_bin
	counter_forward
	r2s_sync
Parameters:
	ADDRESS_WIDTH			- how many memory cell will be
	ALMOST_FULL_THRESHOLD	- deleay between is_full_o & almost_full_o
Ports:
	w_clk_i			- write domain clock
	arst_i			- asynchronous reset
	we_i			- write enable
	is_full_o		- queue is full
	almost_full_o	- queue is almost full
	w_addr_bin_o	- write address to RAM
	w_addr_gray_o	- write address to _read_ctrl
	r_addr_gray_i	- read address from _read_ctrl
Generation:
	if ALMOST_FULL_THRESHOLD > 0:
		flag will be generated
	else:
		flag will be assigned to '0
Additional comments:
	2 ** ADDRESS_WIDTH - ALMOST_FULL_THRESHOLD - 1 must be >= 0
*/
module _write_ctrl #(
	parameter ADDRESS_WIDTH,
	parameter ALMOST_FULL_THRESHOLD
)(
	input	wire							w_clk_i,
	input	wire							arst_i,

	input	wire							we_i,
	output	wire							is_full_o,
	output	wire							almost_full_o,
	//write domain
	output	wire	[ADDRESS_WIDTH - 1:0]	w_addr_bin_o,
	output	wire	[ADDRESS_WIDTH:0]		w_addr_gray_o,
	//read domain
	input	wire	[ADDRESS_WIDTH:0]		r_addr_gray_i
);
wire [ADDRESS_WIDTH:0] ptr_bin;
wire [ADDRESS_WIDTH:0] r_addr_gray_sync;
wire [ADDRESS_WIDTH:0] r_addr_bin_sync;
wire ptr_bin_above;
wire ptr_bin_below;
wire no_counting;
assign no_counting = ~we_i | is_full_o;
assign w_addr_bin_o = ptr_bin[ADDRESS_WIDTH - 1:0];
assign w_addr_gray_o = `BIN_TO_GRAY(ptr_bin);
assign is_full_o = ~(ptr_bin_above | ptr_bin_below);
fast_comparator #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) is_full_cmp (
	.a_i(ptr_bin),
	.b_i({~r_addr_bin_sync[ADDRESS_WIDTH], r_addr_bin_sync[ADDRESS_WIDTH-1:0]}),
	.above_o(ptr_bin_above),
	.below_o(ptr_bin_below)
);
generate
	if (ALMOST_FULL_THRESHOLD > 0) begin
		wire [ADDRESS_WIDTH:0] w_used;
		fast_comparator #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) almost_full_cmp (
			.a_i((ADDRESS_WIDTH+1)'(1 << ADDRESS_WIDTH) - (ADDRESS_WIDTH+1)'(ALMOST_FULL_THRESHOLD) - (ADDRESS_WIDTH+1)'(1)),
			.b_i(w_used),
			.below_o(almost_full_o)
		);
		RCA_M #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) pre_mask_adder (
			.c_i('1),
			.a_i(ptr_bin),
			.b_i(~r_addr_bin_sync),
			.r_o(w_used)
		);
	end else begin
		localparam [0:0] FULLNESS = '0;
		assign almost_full_o = FULLNESS;
	end
endgenerate
gray_to_bin #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) r_addr_bin_conv (
	.data_i(r_addr_gray_sync),
	.data_o(r_addr_bin_sync)
);
counter_forward #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) write_ptr (
	.clk_i(w_clk_i),
	.action_i(no_counting),
	.arst_i(arst_i),
	.data_i(ptr_bin),
	.data_o(ptr_bin)
);
r2s_sync #(.WORD_WIDTH(ADDRESS_WIDTH + 1)) syncer  (
	.clk_dst_i(w_clk_i),
	.arst_i(arst_i),
	.sig_i(r_addr_gray_i), 
	.sig_o(r_addr_gray_sync) 
);
endmodule