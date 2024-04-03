//UART receiver
module _UART_RX #(
	parameter word_width = 8
)(
	input	wire					clk,
	output	wire [word_width - 1:0]	_W,					//complete word (with set parity bits or without them)
	output	wire					R_locked,			//locked = not available
	output	wire					R_counter_state,	//locked = not available
	//UART-UART interface
	input	wire					RX
);
reg [$clog2(word_width + 1) - 1:0] R_counter = '0;		//from the begining we are ready to transmit
reg [word_width:0] _R = '0;
assign R_counter_state = |R_counter;
assign R_locked = R_counter_state | ~_R[word_width];
assign _W = _R[word_width - 1:0];
always @(posedge clk) begin
	_R <= {RX, _R[word_width:1]};
	if (~(_R[word_width - 1] | R_counter_state)) begin
		R_counter <= word_width;
	end else if (R_counter_state) begin
		R_counter <= R_counter - 1;
	end
end
endmodule
//UART transitor
module _UART_TX #(
	parameter word_width = 8
)(
	input	wire					clk,
	input	wire					write,
	input	wire [word_width - 1:0]	_W,					//complete word (with set parity bits or without them)
	output	wire					T_locked,			//locked = not available
	//UART-UART interface
	output	wire					TX
);
reg [$clog2(word_width + 1) - 1:0] T_counter = '0;		//from the begining we are ready to transmit
reg [word_width:0] _T = '0;
assign T_locked = |T_counter;
assign TX = _T[0];
always @(posedge clk) begin
	if (write) begin
		_T <= {_W, 1'b0};
	end else begin
		_T <= {1'b1, _T[word_width:1]};
	end
end
endmodule
//UART with no parity bit
module UART_N #(
	parameter clk_reduction = 16,
	parameter word_width = 8
)(
	input	wire					clk,
	input	wire					write,
	output	wire					R_locked,			//locked = not available
	output	wire					T_locked,			//locked = not available
	output	wire [word_width - 1:0]	R_W,				//complete word (with set parity bits or without them)
	input	wire [word_width - 1:0]	T_W,				//complete word (with set parity bits or without them)
	//UART-UART interface
	input	wire					RX,
	output	wire					TX
);
reg [$clog2(clk_reduction) - 1:0] clk_reductor = '0;
reg [$clog2(clk_reduction) - 1:0] clk_R_sync = '0;
wire clk_state = |clk_reductor;
wire R_counter_state;
_UART_RX #(.word_width(word_width)) rx (
	.clk(clk_reductor == clk_R_sync),
	._W(R_W),
	.R_locked(R_locked),
	.R_counter_state(R_counter_state),
	.RX(RX)
);
_UART_TX #(.word_width(word_width)) tx (
	.clk(~clk_state),
	.write(write & ~T_locked),
	._W(T_W),
	.T_locked(T_locked),
	.TX(TX)
);
always @(posedge clk) begin
	if (clk_state) begin
		clk_reductor = clk_reductor - 1;
	end else begin
		clk_reductor = clk_reduction - 1;
	end
	if (~(RX | R_counter_state)) begin
		clk_R_sync = {~clk_reductor[$clog2(clk_reduction) - 1], clk_reductor[$clog2(clk_reduction) - 2:0]};
	end
end
endmodule
//UART with even parity bit
module UART_E #(
	parameter clk_reduction = 16,
	parameter word_width = 8
) (
	input	wire					clk,
	input	wire					write,
	output	wire					R_damaged,
	output	wire					R_locked,			//locked = not available
	output	wire					T_locked,			//locked = not available
	output	wire [word_width - 1:0]	R_W,				//complete word (with set parity bits or without them)
	input	wire [word_width - 1:0]	T_W,				//complete word (with set parity bits or without them)
	//UART-UART interface
	input	wire					RX,
	output	wire					TX
);
wire [word_width:0] uart_n_r_w;
assign R_damaged = ^uart_n_r_w;
assign R_W = uart_n_r_w[word_width - 1:0];
UART_N #(.clk_reduction(clk_reduction), .word_width(word_width + 1)) uart_n (
	.clk(clk),
	.write(write),
	.R_locked(R_locked),
	.T_locked(T_locked),
	.R_W(uart_n_r_w),
	.T_W({^T_W,T_W}),
	.RX(RX),
	.TX(TX)
);
endmodule