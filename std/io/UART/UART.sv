module UART #(
	parameter WORD_WIDTH,
	parameter BUFFER_ADDRESS_WIDTH,
	parameter RX_ALMOST_FULL_THRESHOLD,
	parameter TX_ALMOST_FULL_THRESHOLD
) (
	input wire clk_i,
	input wire clk_to_RX_i,
	input wire clk_to_TX_i,
	input wire arst_i,

	input wire push_word_i,
	input wire pop_word_i,

	input wire [WORD_WIDTH - 1:0] data_i,
	output wire [WORD_WIDTH - 1:0] data_o,

	input wire RX_i,
	output wire TX_o,
	//we should start reading!
	output wire RX_buffer_full,
	output wire RX_buffer_almost_full,
	//we should stop writing!
	output wire TX_buffer_full,
	output wire TX_buffer_almost_full
);
wire [WORD_WIDTH - 1:0] RX_from_port_to_queue;
wire RX_word_ready;
reg prev_RX_state;
always_ff @(posedge clk_to_RX_i or posedge arst_i) begin
	if (arst_i) begin
		prev_RX_state <= '0;
	end else begin
		prev_RX_state <= RX_word_ready;
	end
end
async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(RX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) RX_buffer (
	.w_clk_i(clk_to_RX_i),
	.r_clk_i(clk_i),
	.arst_i(arst_i),

	.we_i(RX_word_ready & ~prev_RX_state),
	.re_i(pop_word_i),

	.data_i(RX_from_port_to_queue),
	.data_o(data_o),

	.is_full_o(RX_buffer_full),
	.almost_full_o(RX_buffer_almost_full)
);
UART_RX #(.WORD_WIDTH(WORD_WIDTH), .FREQ_PRECISION(4)) RX_LINE (
	.clk_i(clk_to_RX_i),
	.arst_i(arst_i),
	.RX_i(RX_i),
	.data_from_RX_o(RX_from_port_to_queue),
	.data_ready_o(RX_word_ready)
);

wire [WORD_WIDTH - 1:0] TX_from_queue_to_port;
wire TX_line_ready;
wire TX_buffer_empty;
async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(TX_ALMOST_FULL_THRESHOLD), .ALMOST_EMPTY_THRESHOLD(0)) TX_buffer (
	.w_clk_i(clk_i),
	.r_clk_i(clk_to_TX_i),
	.arst_i(arst_i),

	.we_i(push_word_i),
	.re_i(TX_line_ready),

	.data_i(data_i),
	.data_o(TX_from_queue_to_port),

	.is_full_o(TX_buffer_full),
	.almost_full_o(TX_buffer_almost_full),
	.is_empty_o(TX_buffer_empty)
);
UART_TX #(.WORD_WIDTH(WORD_WIDTH)) TX_LINE (
	.clk_i(clk_to_TX_i),
	.arst_i(arst_i),
	.set_word_i(~TX_buffer_empty),
	.data_to_TX_i(TX_from_queue_to_port),
	.TX_o(TX_o),
	.TX_ready_o(TX_line_ready)
);
endmodule