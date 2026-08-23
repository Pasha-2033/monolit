/*
MULTI-MASTER MODE IS NOT SUPPORTED.
We can create task, and continue writing to TX buffer (for example, to write out a series of tasks for several slaves in a single, continuous sequence)
TODO: should we send special values if we don`t write anything or '1 is enough?
*/
module SPI_X_BUF_master #( //master with data fifo (not with data pointers (for other buffers))
	parameter WORD_WIDTH,
	parameter DATA_BUFFER_ADDRESS_WIDTH,
	parameter SLAVE_ADDRESS_WIDTH,
	parameter RX_ALMOST_FULL_THRESHOLD,
	parameter RX_ALMOST_EMPTY_THRESHOLD,
	parameter TX_ALMOST_FULL_THRESHOLD,

	parameter TASK_BUFFER_ADDRESS_WIDTH,
	parameter TASK_ALMOST_FULL_THRESHOLD,

	parameter LINE_WIDTH = 1
) (
	input	wire										clk_i,
	input	wire										X_clk_i,
	input	wire										L_clk_i,
	input	wire										arst_i,
	//data ports
	input	wire										push_word_i,
	input	wire										pop_word_i,
	input	wire	[WORD_WIDTH - 1:0]					data_i,
	output	wire	[WORD_WIDTH - 1:0]					data_o,
	//task ports
	input	wire										push_task_i,
	input	wire										re_i,
	input	wire										we_i,
	input	wire	[DATA_BUFFER_ADDRESS_WIDTH - 1:0]	word_num_i,
	input	wire	[SLAVE_ADDRESS_WIDTH - 1:0]			slave_address_i,

	output	wire	[2 ** SLAVE_ADDRESS_WIDTH - 1:0]	SS_o,
	output	wire										SCLK_o,
	output	wire	[LINE_WIDTH - 1:0]					MOSI_o,
	input	reg		[LINE_WIDTH - 1:0]					MISO_i,

	input	wire										CPOL_i,
	input	wire										CPHA_i,

	//we should start reading!
	output	wire										RX_buffer_full,
	output	wire										RX_buffer_almost_full,
	//we should stop reading!
	output	wire										RX_buffer_empty,
	output	wire										RX_buffer_almost_empty,
	//we should stop writing!
	output	wire										TX_buffer_full,
	output	wire										TX_buffer_almost_full,
	//we should stop giving tasks
	output	wire										task_buffer_full,
	output	wire										task_buffer_almost_full
);
enum reg [1:0] { IDLE, PREPARE, COMMUNICATE, FINISH } state;
reg slave_clk;
reg L_clk_sampled;
wire task_buffer_empty;
wire L_clk_sync;
wire L_CLK_high_front;
wire L_CLK_low_front;
wire read_enabled;
wire write_enabled;
wire communication_ended;
wire TX_buffer_empty;
wire is_active;
wire L_CLK_H_control;
wire L_CLK_L_control;
wire [LINE_WIDTH - 1:0] data_acceptor;
wire [SLAVE_ADDRESS_WIDTH - 1:0] SS_addr;
wire [DATA_BUFFER_ADDRESS_WIDTH - 1:0] word_num;
wire [DATA_BUFFER_ADDRESS_WIDTH - 1:0] word_index;
assign SCLK_o = CPOL_i ^ slave_clk;
assign L_CLK_high_front = ~L_clk_sampled & L_clk_sync;
assign L_CLK_low_front = L_clk_sampled & ~L_clk_sync;
assign is_active = (state == COMMUNICATE) | (state == FINISH);
assign L_CLK_H_control = CPHA_i ? L_CLK_low_front : L_CLK_high_front;
assign L_CLK_L_control = CPHA_i ? L_CLK_high_front : L_CLK_low_front;
assign MOSI_o = ((state == IDLE) | ~write_enabled) ? {LINE_WIDTH{1'b1}} : data_acceptor;
always_ff @(posedge arst_i or posedge X_clk_i) begin
	if (arst_i) begin
		state <= IDLE;
		slave_clk <= '0;
		L_clk_sampled <= '0;
	end else begin
		L_clk_sampled <= L_clk_sync;
		case (state)
			IDLE: begin
				if (~task_buffer_empty & L_CLK_low_front) begin
					state <= PREPARE;
				end
			end
			PREPARE: begin
				if (L_CLK_high_front) begin
					state <= COMMUNICATE;
					slave_clk <= L_clk_sync;
				end
			end
			COMMUNICATE: begin
				slave_clk <= L_clk_sync;
				if (communication_ended & L_CLK_low_front) begin
					state <= FINISH;
				end
			end
			FINISH: begin
				if (L_CLK_high_front) begin
					state <= IDLE;
				end else begin
					slave_clk <= L_clk_sync;
				end
			end
		endcase
	end
end
r2s_sync #(.WORD_WIDTH(1), .WORD_RESET(0)) L_CLK_syncer (
	.clk_dst_i(X_clk_i),
	.arst_i(arst_i),
	.sig_i(L_clk_i),
	.sig_o(L_clk_sync)
);
tree_decoder #(.OUTPUT_WIDTH(2 ** SLAVE_ADDRESS_WIDTH), .OUTPUT_INVERSED(1)) slave_selection (
	.enable_i(state != IDLE),
	.select_i(SS_addr),
	.data_o(SS_o)
);
async_queue #(.WORD_WIDTH(SLAVE_ADDRESS_WIDTH + DATA_BUFFER_ADDRESS_WIDTH + 2), .ADDRESS_WIDTH(TASK_BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TASK_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) task_buffer (
	.w_clk_i(clk_i),
	.r_clk_i(X_clk_i),
	.arst_i(arst_i),
	.we_i(push_task_i),
	.re_i((state == FINISH) & L_CLK_high_front),
	.data_i({slave_address_i, word_num_i, we_i, re_i}),
	.data_o({SS_addr, word_num, write_enabled, read_enabled}),
	.is_full_o(task_buffer_full),
	.almost_full_o(task_buffer_almost_full),
	.is_empty_o(task_buffer_empty)
);
generate
	if (WORD_WIDTH == LINE_WIDTH) begin
		counter_backward #(.WORD_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .WORD_RESET(0)) word_counter (
			.clk_i(X_clk_i),
			.action_i((state == PREPARE) | (~L_CLK_L_control & (state != IDLE))),
			.arst_i(arst_i),
			.data_i((state == PREPARE) ? word_num : word_index),
			.data_o(word_index),
			.will_underflow_o(communication_ended)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(RX_ALMOST_EMPTY_THRESHOLD)) RX_buffer (
			.w_clk_i(X_clk_i),
			.r_clk_i(clk_i),
			.arst_i(arst_i),
			.we_i(((state == COMMUNICATE) | (state == PREPARE)) & L_CLK_H_control & read_enabled & ~RX_buffer_full), //we use ~RX_buffer_full for preventing async_queue overflow, if tasks are ahead of data (dear developer, watch your actions!)
			.re_i(pop_word_i),
			.data_i(MISO_i), //TODO: should we use r2s_sync for MISO_i?
			.data_o(data_o),
			.is_full_o(RX_buffer_full),
			.almost_full_o(RX_buffer_almost_full),
			.is_empty_o(RX_buffer_empty),
			.almost_empty_o(RX_buffer_almost_empty)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
			.w_clk_i(clk_i),
			.r_clk_i(X_clk_i),
			.arst_i(arst_i),
			.we_i(push_word_i),
			.re_i(is_active & L_CLK_L_control & write_enabled & ~TX_buffer_empty), //we use ~TX_buffer_empty for preventing async_queue overflow, if tasks are ahead of data (dear developer, watch your actions!)
			.data_i(data_i),
			.data_o(data_acceptor),
			.is_full_o(TX_buffer_full),
			.almost_full_o(TX_buffer_almost_full),
			.is_empty_o(TX_buffer_empty)
		);
	end else begin
		localparam TX_LINE_RATIO = WORD_WIDTH / LINE_WIDTH;
		localparam TX_ADDR_WIDTH = $clog2(TX_LINE_RATIO);
		reg [WORD_WIDTH - 1:0] shift_reg;
		wire [TX_ADDR_WIDTH - 1:0] tx_addr;
		wire [TX_LINE_RATIO - 1:0][LINE_WIDTH - 1:0] TX_value;
		wire tx_addr_underflow;
		wire tx_load;
		assign data_acceptor = TX_value[tx_addr];
		assign tx_load = tx_addr_underflow & L_CLK_L_control & is_active;
		always_ff @(posedge arst_i or posedge L_CLK_H_control) begin
			if (arst_i) begin
				shift_reg <= '0;
			end else begin
				shift_reg <= {shift_reg[WORD_WIDTH - LINE_WIDTH - 1:0], MISO_i}; //TODO: should we use r2s_sync for MISO_i?
			end
		end
		if (`IS_2POW(LINE_WIDTH)) begin
			assign tx_addr_underflow = ~|tx_addr;
			counter_backward #(.WORD_WIDTH(DATA_BUFFER_ADDRESS_WIDTH + TX_ADDR_WIDTH), .WORD_RESET()) tx_bit_counter (
				.clk_i(X_clk_i),
				.action_i((is_active & ~L_CLK_L_control) | (state == PREPARE)),
				.arst_i(arst_i),
				.data_i((state == PREPARE) ? {word_num, {TX_ADDR_WIDTH{1'b1}}} : {word_index, tx_addr}),
				.data_o({word_index, tx_addr}),
				.will_underflow_o(communication_ended)
			);
		end else begin
			wire word_underflow;
			assign communication_ended = tx_addr_underflow & word_underflow;
			counter_backward #(.WORD_WIDTH(TX_ADDR_WIDTH), .WORD_RESET(0)) tx_bit_counter (
				.clk_i(X_clk_i),
				.action_i((is_active & (~L_CLK_L_control | tx_addr_underflow)) | (state == IDLE) | (state == PREPARE)),
				.arst_i(arst_i),
				.data_i(((state == PREPARE) | tx_load) ? TX_LINE_RATIO - 1 : tx_addr),
				.data_o(tx_addr),
				.will_underflow_o(tx_addr_underflow)
			);
			counter_backward #(.WORD_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .WORD_RESET(0)) word_counter (
				.clk_i(X_clk_i),
				.action_i(~(tx_addr_underflow & L_CLK_L_control) | (state == PREPARE)),
				.arst_i(arst_i),
				.data_i((state == PREPARE) ? word_num : word_index),
				.data_o(word_index),
				.will_underflow_o(word_underflow)
			);
		end
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(RX_ALMOST_EMPTY_THRESHOLD)) RX_buffer (
			.w_clk_i(X_clk_i),
			.r_clk_i(clk_i),
			.arst_i(arst_i),
			.we_i(is_active & L_CLK_L_control & tx_addr_underflow & read_enabled & ~RX_buffer_full), //we use ~RX_buffer_full for preventing async_queue overflow, if tasks are ahead of data (dear developer, watch your actions!)
			.re_i(pop_word_i),
			.data_i(shift_reg),
			.data_o(data_o),
			.is_full_o(RX_buffer_full),
			.almost_full_o(RX_buffer_almost_full),
			.is_empty_o(RX_buffer_empty),
			.almost_empty_o(RX_buffer_almost_empty)
		);
		async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(DATA_BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
			.w_clk_i(clk_i),
			.r_clk_i(X_clk_i),
			.arst_i(arst_i),
			.we_i(push_word_i),
			.re_i(tx_load & write_enabled & ~TX_buffer_empty), //we use ~TX_buffer_empty for preventing async_queue overflow, if tasks are ahead of data (dear developer, watch your actions!)
			.data_i(data_i),
			.data_o(TX_value),
			.is_full_o(TX_buffer_full),
			.almost_full_o(TX_buffer_almost_full),
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