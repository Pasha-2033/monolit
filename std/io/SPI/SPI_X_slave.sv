module SPI_X_slave #(
	parameter WORD_WIDTH,
    parameter BUFFER_ADDRESS_WIDTH,
	parameter RX_ALMOST_FULL_THRESHOLD,
	parameter RX_ALMOST_EMPTY_THRESHOLD,
	parameter TX_ALMOST_FULL_THRESHOLD
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
    input	wire						MOSI_i,
    output	reg							MISO_o,

    input	wire						CPOL,
    input	wire						CPHA,

	//we should start reading!
	output	wire						RX_buffer_full,
	output	wire						RX_buffer_almost_full,
	//we should stop reading!
	output	wire						RX_buffer_empty,
	output	wire						RX_buffer_almost_empty,
	//we should stop writing!
	output	wire						TX_buffer_full,
	output	wire						TX_buffer_almost_full
);
reg [WORD_WIDTH - 1:0] shift_reg;
reg L_clk_sampled;
reg RV_sampled;
reg SS_sampled;
reg SR_unloaded;
wire L_clk_sync;
wire SS_sync;
wire L_clk_lvl;
wire L_clk_front;
wire SS_low_front;
wire RV_high_front;
wire L_CLK_high_front;
wire TX_buffer_empty;
wire shift_reg_valid;
wire [WORD_WIDTH - 1:0] TX_from_queue_to_shift;
assign L_clk_lvl = SCLK_i ^ CPOL;
assign L_clk_front = CPHA ? ~L_clk_lvl : L_clk_lvl;
assign SS_low_front = SS_sampled & ~SS_sync;
assign RV_high_front = ~RV_sampled & shift_reg_valid;
assign L_CLK_high_front = ~L_clk_sampled & L_clk_sync & ~SS_i;
always_ff @(posedge arst_i or posedge X_clk_i) begin
	if (arst_i) begin
		shift_reg <= '0;
		L_clk_sampled <= '0;
		RV_sampled <= '0;
		SS_sampled <= '0;
		SR_unloaded <= '1;
		MISO_o <= '0;
	end else begin
		L_clk_sampled <= L_clk_sync;
		RV_sampled <= shift_reg_valid;
		SS_sampled <= SS_sync;
		if (L_CLK_high_front) begin
			MISO_o <= shift_reg[WORD_WIDTH - 1];
		end
		if (RV_high_front | SS_low_front) begin
			shift_reg <= TX_from_queue_to_shift;
			SR_unloaded <= ~TX_buffer_empty;
		end else if (L_CLK_high_front) begin
			shift_reg <= {shift_reg[WORD_WIDTH - 2:0], MOSI_i};
			SR_unloaded <= '1;
		end
	end
end
r2s_sync #(.WORD_WIDTH(1), .WORD_RESET(0)) L_clk_syncer (
	.clk_dst_i(X_clk_i),
	.arst_i(arst_i),
	.sig_i(L_clk_front),
	.sig_o(L_clk_sync)
);
r2s_sync #(.WORD_WIDTH(1), .WORD_RESET(0)) SS_syncer (
	.clk_dst_i(X_clk_i),
	.arst_i(arst_i),
	.sig_i(SS_i),
	.sig_o(SS_sync)
);
counter_backward #(.WORD_WIDTH($clog2(WORD_WIDTH + 1)), .WORD_RESET(WORD_WIDTH)) bit_counter (
	.clk_i(L_CLK_high_front),
	.action_i(SS_i | shift_reg_valid),
	.arst_i(arst_i | (SS_i & ~shift_reg_valid)),
	.data_i(WORD_WIDTH - 1),
	.will_underflow_o(shift_reg_valid)
);
async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(RX_ALMOST_EMPTY_THRESHOLD)) RX_buffer (
	.w_clk_i(X_clk_i),
	.r_clk_i(clk_i),
	.arst_i(arst_i),

	.we_i(RV_high_front),
	.re_i(pop_word_i),

	.data_i({shift_reg[WORD_WIDTH - 2:0], MOSI_i}),
	.data_o(data_o),

	.is_full_o(RX_buffer_full),
	.almost_full_o(RX_buffer_almost_full),
	.is_empty_o(RX_buffer_empty),
	.almost_empty_o(RX_buffer_almost_empty)
);
async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
	.w_clk_i(clk_i),
	.r_clk_i(X_clk_i),
	.arst_i(arst_i),

	.we_i(push_word_i),
	.re_i((RV_high_front | SS_low_front) & ~TX_buffer_empty & SR_unloaded),

	.data_i(data_i),
	.data_o(TX_from_queue_to_shift),

	.is_full_o(TX_buffer_full),
	.almost_full_o(TX_buffer_almost_full),
	.is_empty_o(TX_buffer_empty)
);
endmodule