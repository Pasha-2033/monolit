`define UART_ONESTOPBIT		2'h0	//TODO (replace to enum)
`define UART_ONE5STOPBITS	2'h1
`define UART_TWOSTOPBITS	2'h2
`define UART_NOPARITY		3'h0
`define UART_ODDPARITY		3'h1
`define UART_EVENPARITY		3'h2
`define UART_SPACEPARITY	3'h3
`define UART_MARKPARITY		3'h4
//UART receiver
module _UART_RX #(
	parameter word_width = 8,
	parameter reductor_width = 4
)(
	input	wire					clk,
	input	wire [1:0]				stopbitnum,
	input	wire [2:0]				paritytype,
	output	reg  [word_width - 1:0]	word,
	output	wire					word_parity_status,
	output	wire					word_stop_status,
	output	wire [1:0]				receiver_state,
	//UART-UART interface
	input	wire					RX
);
reg [reductor_width - 1:0] reductor_to_tick;
reg parity;
reg [1:0] stopbits;
wire [word_width:0] word_with_parity = {parity, word};
wire action_counter_overflow;
wire [reductor_width - 1:0] reductor_value;
counter_cs_backward #(.word_width($clog2(word_width))) action_counter (
	.clk((tick & (state == RECEIVING_WORD)) | (~RX & (state == IDLE))),
	.action(~RX & (state == IDLE)),
	.reset('0),
	.D_IN(word_width - 1),
	.D_OUT(word_counter_value),
	.will_overflow(action_counter_overflow)
);
counter_cs_forward #(.word_width(reductor_width)) reductor (
	.clk(clk),
	.action('0),
	.reset('0),
	.D_IN('0),
	.D_OUT(reductor_value)
);
enum reg [1:0] {IDLE, RECEIVING_WORD, RECEIVING_PARITY, RECEIVING_STOPBITS} state = IDLE;
wire tick = (reductor_value == reductor_to_tick);
wire half_tick = ({~reductor_value[reductor_width - 1], reductor_value[reductor_width - 2:0]} == reductor_to_tick);
wire word_xor_parity = ^word_with_parity;
wire [4:0] parities = {
	2'b0,				//TODO (UART_MARKPARITY & UART_SPACEPARITY)
	~word_xor_parity,	//UART_EVENPARITY
	word_xor_parity,	//UART_ODDPARITY
	1'b1				//UART_NOPARITY
};
assign word_parity_status = parities[paritytype];
assign word_stop_status = &stopbits;
assign receiver_state = state;
always @(posedge clk) begin
	case (state)
		IDLE: begin
			if (~RX) begin
				state <= RECEIVING_WORD;
				stopbits <= 2'b0;
				reductor_to_tick <= {~reductor_value[reductor_width - 1], reductor_value[reductor_width - 2:0]};
			end
		end
		RECEIVING_WORD: begin
			if (tick) begin
				//NOTE: this line defines wich side shift is made
				word <= {RX, word[word_width - 1:1]};
				if (action_counter_overflow) begin
					state <= paritytype == `UART_NOPARITY ? RECEIVING_STOPBITS : RECEIVING_PARITY;
				end
			end
		end
		RECEIVING_PARITY: begin
			if (tick) begin
				parity <= RX;
				state <= RECEIVING_STOPBITS;
			end
		end
		RECEIVING_STOPBITS: begin
			if (~stopbits[0] & tick) begin
				if (RX) begin
					if (stopbitnum == `UART_ONESTOPBIT) begin
						state <= IDLE;
						stopbits[1] <= '1;
					end
					stopbits[0] <= RX;
				end else begin
					state <= IDLE;
				end
			end
			if (stopbits[0] & (stopbitnum == `UART_ONE5STOPBITS ? half_tick : tick)) begin
				stopbits[1] <= RX;
				state <= IDLE;
			end
		end
	endcase
end
endmodule
//UART transitor
module _UART_TX #(
	parameters
) (
	input	wire					clk,
	//UART-UART interface
	output	wire					TX
);
	
endmodule