/*
Provides: 
	UART recieving line
Dependencies:
	counter_backward
Parameters:
	WORD_WIDTH		- width of data value
	FREQ_PRECISION	- = clk_i/RX clock
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	RX_i			- recieving line
	data_from_RX_o	- data value
	data_ready_o	- is data recieved and actual
Generation:
	NONE
Additional comments:
	FREQ_PRECISION MUST BE > 1!!!
	doesn`t support 1,5x & 2x stop signals (but can be wrapped)
	doesn`t support parity bit (but can be wrapped)
	RX: WORD_WIDTH-N-1
*/
module UART_RX #(
	parameter WORD_WIDTH,
	parameter FREQ_PRECISION = 2
) (
	input	wire						clk_i,
	input	wire						arst_i,
	input	wire						RX_i,
	output	wire	[WORD_WIDTH - 1:0]	data_from_RX_o,
	output	wire						data_ready_o
);
enum reg { IDLE, RECIEVE } state;
reg [WORD_WIDTH:0] word_container;
assign data_ready_o = word_container[WORD_WIDTH] & ~state;
assign data_from_RX_o = word_container[WORD_WIDTH - 1:0];

wire step_underflow;
wire bit_underflow;
localparam INIT_STEP = FREQ_PRECISION + FREQ_PRECISION / 2 - 1;
counter_backward #(.WORD_WIDTH($clog2(INIT_STEP + 1)), .WORD_RESET(INIT_STEP)) step_counter (
	.clk_i(clk_i),
	.action_i(step_underflow),
	.arst_i(arst_i | ~state),
	.data_i(FREQ_PRECISION - 1),
	.will_underflow_o(step_underflow)
);
counter_backward #(.WORD_WIDTH($clog2(WORD_WIDTH + 2)), .WORD_RESET(WORD_WIDTH + 1)) bit_counter (
	.clk_i(step_underflow),
	.action_i('0),
	.arst_i(arst_i | ~state),
	.data_i('0),
	.will_underflow_o(bit_underflow)
);

always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		word_container <= '0;
		state <= IDLE;
	end else begin
		if (step_underflow) begin
			word_container <= {RX_i, word_container[WORD_WIDTH:1]};
		end
		case (state)
			IDLE: begin
				if (~RX_i) begin
					state <= RECIEVE;
				end
			end
			RECIEVE: begin
				if (bit_underflow) begin
					state <= IDLE;
				end
			end
		endcase
	end
end
endmodule