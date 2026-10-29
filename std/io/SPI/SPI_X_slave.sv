/*
DO NOT OVERFLOW async_queue!
*/
module SPI_X_slave #(
	parameter WORD_WIDTH,
	parameter BUFFER_ADDRESS_WIDTH,
	parameter RX_ALMOST_FULL_THRESHOLD,
	parameter RX_ALMOST_EMPTY_THRESHOLD,
	parameter TX_ALMOST_FULL_THRESHOLD,
	parameter LINE_WIDTH = 1
) (
	input	wire						clk_i,
	input	wire						X_clk_i,
	input	wire						arst_i,

	input	wire						push_word_i,
	input	wire						pop_word_i,
	input	wire	[WORD_WIDTH - 1:0]	data_i,
	output	wire	[WORD_WIDTH - 1:0]	data_o,

	input	wire						SCLK_i,
	input	wire						SS_i,
	input	wire	[LINE_WIDTH - 1:0]	MOSI_i,
	output	wire	[LINE_WIDTH - 1:0]	MISO_o,

	input	wire						CPOL_i,
	input	wire						CPHA_i,

	//we should start reading!
	output	wire						RX_buffer_full_o,
	output	wire						RX_buffer_almost_full_o,
	//we should stop reading!
	output	wire						RX_buffer_empty_o,
	output	wire						RX_buffer_almost_empty_o,
	//we should stop writing!
	output	wire						TX_buffer_full_o,
	output	wire						TX_buffer_almost_full_o
);
reg SS_sampled;
reg CPHA_delay;
reg L_clk_sampled;
wire SS_sync;
wire L_clk_sync;
wire L_CLK_high_front;
wire L_CLK_low_front;
wire L_CLK_H_control;
wire L_CLK_L_control;
wire TX_buffer_empty;
wire [LINE_WIDTH - 1:0] data_acceptor;
assign L_CLK_high_front = ~L_clk_sampled & L_clk_sync & ~SS_i & ~CPHA_delay;
assign L_CLK_low_front = L_clk_sampled & ~L_clk_sync & ~SS_i;
assign L_CLK_H_control = CPHA_i ? L_CLK_low_front : L_CLK_high_front;
assign L_CLK_L_control = CPHA_i ? L_CLK_high_front : L_CLK_low_front;
assign MISO_o = data_acceptor | {LINE_WIDTH{SS_i}}; //if we are not selected - we do not affect line with our zeros; TODO: should we send special values if we are empty?
always_ff @(posedge arst_i or posedge X_clk_i) begin
	if (arst_i) begin
		L_clk_sampled <= '0;
		SS_sampled <= '1;
	end else begin
		SS_sampled <= SS_sync;
		L_clk_sampled <= L_clk_sync;
		if (SS_sampled & ~SS_sync) begin
			CPHA_delay <= CPHA_i;
		end else if ((L_clk_sampled & ~L_clk_sync) | SS_sync) begin
			CPHA_delay <= '0;
		end
	end
end
r2s_sync #(.WORD_WIDTH(1), .WORD_RESET(0)) L_clk_syncer (
	.clk_dst_i(X_clk_i),
	.arst_i(arst_i),
	.sig_i(SCLK_i ^ CPOL_i),
	.sig_o(L_clk_sync)
);
r2s_sync #(.WORD_WIDTH(1), .WORD_RESET(1)) SS_syncer (
	.clk_dst_i(X_clk_i),
	.arst_i(arst_i),
	.sig_i(SS_i),
	.sig_o(SS_sync)
);
generate
	if (WORD_WIDTH == LINE_WIDTH) begin
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(RX_ALMOST_EMPTY_THRESHOLD)) RX_buffer (
			.w_clk_i(X_clk_i),
			.r_clk_i(clk_i),
			.arst_i(arst_i),
			.we_i(L_CLK_H_control & ~RX_buffer_full_o),
			.re_i(pop_word_i),
			.data_i(MOSI_i), //TODO: should we use r2s_sync for MOSI_i?
			.data_o(data_o),
			.is_full_o(RX_buffer_full_o),
			.almost_full_o(RX_buffer_almost_full_o),
			.is_empty_o(RX_buffer_empty_o),
			.almost_empty_o(RX_buffer_almost_empty_o)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
			.w_clk_i(clk_i),
			.r_clk_i(X_clk_i),
			.arst_i(arst_i),
			.we_i(push_word_i),
			.re_i((L_CLK_L_control | (CPHA_i & ~SS_sampled & SS_sync)) & ~TX_buffer_empty),
			.data_i(data_i),
			.data_o(data_acceptor),
			.is_full_o(TX_buffer_full_o),
			.almost_full_o(TX_buffer_almost_full_o),
			.is_empty_o(TX_buffer_empty)
		);
	end else begin
		localparam TX_LINE_RATIO = WORD_WIDTH / LINE_WIDTH;
		localparam TX_ADDR_WIDTH = $clog2(TX_LINE_RATIO);
		reg [WORD_WIDTH - 1:0] shift_reg;
		reg tx_addr_delay;
		wire [TX_LINE_RATIO - 1:0][LINE_WIDTH - 1:0] TX_value;
		wire [TX_ADDR_WIDTH - 1:0] tx_addr;
		wire tx_addr_underflow;
		assign data_acceptor = TX_value[tx_addr];
		always_ff @(posedge arst_i or posedge X_clk_i) begin
			if (arst_i) begin
				tx_addr_delay <= '0;
			end else begin
				tx_addr_delay <= tx_addr_underflow;
			end
		end
		always_ff @(posedge arst_i or posedge L_CLK_H_control) begin
			if (arst_i) begin
				shift_reg <= '0;
			end else begin
				shift_reg <= {shift_reg[WORD_WIDTH - LINE_WIDTH - 1:0], MOSI_i}; //TODO: should we use r2s_sync for MOSI_i?
			end
		end
		counter_backward #(.WORD_WIDTH(TX_ADDR_WIDTH), .WORD_RESET(TX_LINE_RATIO - 1)) tx_bit_counter (
			.clk_i(X_clk_i),
			.action_i(tx_addr_underflow | ~L_CLK_L_control),
			.arst_i(arst_i | SS_i),
			.data_i((tx_addr_underflow & L_CLK_L_control) ? TX_LINE_RATIO - 1 : tx_addr),
			.data_o(tx_addr),
			.will_underflow_o(tx_addr_underflow)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(RX_ALMOST_EMPTY_THRESHOLD)) RX_buffer (
			.w_clk_i(X_clk_i),
			.r_clk_i(clk_i),
			.arst_i(arst_i),
			.we_i(tx_addr_delay & ~tx_addr_underflow & ~RX_buffer_full_o),
			.re_i(pop_word_i),
			.data_i(shift_reg),
			.data_o(data_o),
			.is_full_o(RX_buffer_full_o),
			.almost_full_o(RX_buffer_almost_full_o),
			.is_empty_o(RX_buffer_empty_o),
			.almost_empty_o(RX_buffer_almost_empty_o)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
			.w_clk_i(clk_i),
			.r_clk_i(X_clk_i),
			.arst_i(arst_i),
			.we_i(push_word_i),
			.re_i(((tx_addr_underflow & L_CLK_L_control) | (CPHA_i & ~SS_sampled & SS_sync)) & ~TX_buffer_empty),
			.data_i(data_i),
			.data_o(TX_value),
			.is_full_o(TX_buffer_full_o),
			.almost_full_o(TX_buffer_almost_full_o),
			.is_empty_o(TX_buffer_empty)
		);
	end
endgenerate
initial begin
	if (WORD_WIDTH % LINE_WIDTH) begin
		$warning(".LINE_WIDTH(%d) is not a multiple of .WORD_WIDTH(%d), line will be with losses!", LINE_WIDTH, WORD_WIDTH);
	end
end
endmodule