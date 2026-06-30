/*
Provides: 
	UART transmiting line
Dependencies:
	counter_backward
Parameters:
	WORD_WIDTH		- width of data value
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	set_word_i		- set word for transmition
	data_to_TX_i	- value to transmit
	TX_o			- transmiting line
	TX_ready_o		- ready for transmition
Generation:
	NONE
Additional comments:
	won`t accept any words during the transmition
	doesn`t support 1,5x & 2x stop signals (but can be wrapped)
	doesn`t support parity bit (but can be wrapped)
	TX: WORD_WIDTH-N-1
*/
module UART_TX #(
	WORD_WIDTH
) (
	input	wire						clk_i,
	input	wire						arst_i,
	input	wire						set_word_i,
	input	wire	[WORD_WIDTH - 1:0]	data_to_TX_i,
	output	wire						TX_o,
	output	wire						TX_ready_o
);
enum reg { IDLE, TRANSMIT } state;
reg [WORD_WIDTH:0] word_container;
assign TX_o = word_container[0];

assign TX_ready_o = ~state;

wire bit_underflow;
counter_backward #(.WORD_WIDTH($clog2(WORD_WIDTH + 1)), .WORD_RESET(WORD_WIDTH)) bit_counter (
	.clk_i(clk_i),
	.action_i('0),
	.arst_i(arst_i | ~state),
	.data_i('0),
	.will_underflow_o(bit_underflow)
);

always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		word_container <= '1;
		state <= IDLE;
	end else begin
		case (state)
			IDLE: begin
				if (set_word_i) begin
					word_container <= {data_to_TX_i, 1'b0};
					state <= TRANSMIT;
				end
			end
			TRANSMIT: begin
				word_container <= {1'b1, word_container[WORD_WIDTH:1]};
				if (bit_underflow) begin
					state <= IDLE;
				end
			end
		endcase
	end
end
endmodule