module main (
	input wire clk,
	input wire [31:0] D_IN,
	output wire [63:0] D_OUT
);
//Fast adder
wire P, G, C_OUT, C_IN;
fast_adder #(.cascade_size(4), .bit_width(16)) fa (
	C_IN, 
	D_IN[15:0], 
	D_IN[31:16], 
	D_OUT[15:0], 
	P, 
	G, 
	C_OUT
);
//UART
wire RX, TX;
wire R_locked, T_locked;
UART_N #(.clk_reduction(64), .word_width(8)) uart_n (
	.clk(clk),
	.write(D_IN[0]),
	.R_locked(R_locked),
	.T_locked(T_locked),
	.R_W(D_OUT[23:16]),
	.T_W(D_IN[9:2]),
	.RX(D_IN[1]),
	.TX(D_OUT[24])
);
//Counter (complex)
counter_c #(.word_width(8)) cc (
	.clk(clk)
);
//cash
_fbsoc_string_container #(.address_size(4), .data_size(4), .cash_length(16)) str_con (
	.clk(clk),
	.write(D_IN[0]),
	.index(D_IN[3:1]),
	.D_IN(D_IN[7:4]),
	.D_OUT(D_OUT[28:25])
);
endmodule