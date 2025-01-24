module main (
	input wire clk,
	input wire [31:0] D_IN,
	output wire [2 ** 5 - 1:0] D_OUT
);
//Fast adder
wire P, G, C, C_IN;
RCA_M #(.word_width(16)) rca_m (
	.C_IN(C_IN),
	.A(D_IN[15:0]),
	.B(D_IN[31:16])
);
CLAA #(.cascade_size(4), .word_width(16)) claa (
	.C_IN(C_IN), 
	.A(D_IN[15:0]), 
	.B(D_IN[31:16])
);
//Fast comparator
fast_comparator #(.word_width(1)) fc (
	.A(D_IN[15:0]),
	.B(D_IN[31:16])
);
//IIC
IIC #(.word_width(8)) iic (
	.clk(clk)
);
//SPI
SPI #(.word_width(8), .SS_width(1)) spi (
	.clk(clk)
);
//Counter (complex)
counter #(.word_width(8)) cc (
	.clk(clk)
);
counter_forward #(.word_width(8)) ccsf (
	.clk(clk)
);
counter_backward #(.word_width(8)) ccsb (
	.clk(clk)
);
//decoder
_array_decoder #(.output_width(2 ** 5)) dec (
	.select(D_IN[12:0]),
	.out(D_OUT)
);
_tree_decoder #(.output_width(12)) dec2 (
	.select(D_IN[3:0])
);
//encoder
encoder #(.input_width(5)) enc (
	.select(D_IN[4:0])
);
encoder #(.input_width(17)) enc2 (
	.select(D_IN[16:0])
);
//shifts
wire [7:0] D = D_IN[7:0];
polyshift_l #(.word_width(8)) psl (
	.C_IN(`RCL(D, D_IN[13])),
	.D_IN(D),
	.shift_size(D_IN[10:8]),
	.shift_type(D_IN[12:11])
);
polyshift_r #(.word_width(8)) psr (
	.C_IN(`RCR(D, D_IN[13])),
	.D_IN(D),
	.shift_size(D_IN[10:8]),
	.shift_type(D_IN[12:11])
);
//cash
_fbsoc_string_container #(.address_size(4), .data_size(4), .cash_length(16)) str_con (
	.clk(clk),
	.write(D_IN[0]),
	.index(D_IN[4:1]),
	.D_IN(D_IN[8:5])
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