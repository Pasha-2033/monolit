module UART #(
	WORD_WIDTH,
	BUFFER_ADDRESS_WIDTH
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
	output wire TX_o
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
async_queue #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH), .ALMOST_FULL_THRESHOLD(2), .ALMOST_EMPTY_THRESHOLD(2)) RX_buffer (
	.w_clk_i(clk_to_RX_i),
	.r_clk_i(clk_i),
	.arst_i(arst_i),

	.we_i(RX_word_ready & ~prev_RX_state),
	.re_i(pop_word_i),

	.data_i(RX_from_port_to_queue),
	.data_o(data_o)

	//.is_full_o(),
	//.almost_full_o(),
	//.is_empty_o(),
	//.almost_empty_o()
);
UART_RX #(.WORD_WIDTH(WORD_WIDTH), .FREQ_PRECISION(4)) RX_LINE (
	.clk_i(clk_to_RX_i),
	.arst_i(arst_i),
	.RX_i(RX_i),
	.data_from_RX_o(RX_from_port_to_queue),
	.data_ready_o(RX_word_ready)
);

/*
localparam CLK_REDUCTION = 10;
wire [WORD_WIDTH - 1:0] RX_from_port_to_queue;
wire RX_word_ready;
reg prev_RX_state;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		prev_RX_state <= '0;
	end else begin
		prev_RX_state <= RX_word_ready;
	end
end
sync_queue_bin #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH)) RX_buffer (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.push_i(RX_word_ready & ~prev_RX_state),
	.pop_i(pop_word_i),
	.data_i(RX_from_port_to_queue),
	.data_o(data_o),
	.is_full_o(RX_buffer_overflow),
	.is_empty_o(RX_buffer_underflow)
);
UART_RX #(.WORD_WIDTH(WORD_WIDTH), .FREQ_PRECISION(CLK_REDUCTION)) RX_LINE (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.RX_i(RX_i),
	.data_from_RX_o(RX_from_port_to_queue),
	.data_ready_o(RX_word_ready)
);

wire [WORD_WIDTH - 1:0] TX_from_queue_to_port;
wire TX_buffer_empty;
wire TX_line_ready;
wire reduced_TX_clk;
reg prev_TX_state;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		prev_TX_state <= '0;
	end else begin
		prev_TX_state <= TX_line_ready;
	end
end
const_clk_reductor #(.REDUCTION(CLK_REDUCTION / 2)) reductor (
	.arst_i(arst_i),
	.clk_i(clk_i),
	.clk_o(reduced_TX_clk)
);
sync_queue_bin #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH)) TX_buffer (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.push_i(push_word_i & ~TX_buffer_overflow),
	.pop_i(~TX_buffer_empty & TX_line_ready & ~prev_TX_state),
	.data_i(data_i),
	.data_o(TX_from_queue_to_port),
	.is_full_o(TX_buffer_overflow),
	.is_empty_o(TX_buffer_empty)
);
UART_TX #(.WORD_WIDTH(WORD_WIDTH)) TX_LINE (
	.clk_i(reduced_TX_clk),
	.arst_i(arst_i),
	.set_word_i(~TX_buffer_empty),
	.data_to_TX_i(TX_from_queue_to_port),
	.TX_o(TX_o),
	.TX_ready_o(TX_line_ready)
);
*/
endmodule