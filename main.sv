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
_UART_RX rx (
	.clk(clk),
	.RX(D_IN[1])
);
//Counter (complex)
counter_c #(.word_width(8)) cc (
	.clk(clk)
);
counter_cs_forward #(.word_width(8)) ccsf (
	.clk(clk)
);
counter_cs_backward #(.word_width(8)) ccsb (
	.clk(clk)
);
//encoder
encoder #(.input_width(5)) enc (
	.select(D_IN[4:0])
);
encoder #(.input_width(17)) enc2 (
	.select(D_IN[16:0])
);
//shifts
polyshift_l #(.word_width(8)) psl (
	.D_IN(D_IN[7:0])
);
polyshift_r #(.word_width(8)) psr (
	.D_IN(D_IN[7:0])
);
//cash
_fbsoc_string_container #(.address_size(4), .data_size(4), .cash_length(16)) str_con (
	.clk(clk),
	.write(D_IN[0]),
	.index(D_IN[4:1]),
	.D_IN(D_IN[8:5]),
	.D_OUT(D_OUT[28:25])
);



_fuc_ll_container #(.address_size(4), .data_size(4), .cash_length(16)) fuc_s (
	.clk(clk),
	.action(D_IN[0]),
	.address(D_IN[4:1]),
	.data(D_IN[28:25])
);
fast_unordered_cash #(.address_size(4), .data_size(4), .cash_length(16), .call_time_size(4)) fuc (
	.clk(clk),
	.action(D_IN[0]),
	.address(D_IN[4:1]),
	.data(D_IN[8:5])
);
endmodule