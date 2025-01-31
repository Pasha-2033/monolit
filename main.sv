module main (
	input wire clk,
	input wire [31:0] D_IN,
	output wire [2 ** 5 - 1:0] D_OUT
);
//Fast adder
wire P;
wire G;
wire C_IN;
RCA_M #(.word_width(16)) rca_m (
	.C_IN(C_IN),
	.A(D_IN[15:0]),
	.B(D_IN[31:16])
);
CLAA #(.word_width(32)) claa (
	.C_IN(C_IN), 
	.A(D_IN[15:0]), 
	.B(D_IN[31:16])
);
CSA_S #(.unit_width(5), .word_width(15)) csa_s (
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
parameter C = 1'b0; 
wire [6:0] DCR = D[6:0];
wire [6:0] DCL = D[7:1];
polyshift_l #(.word_width(8)) psl (
	.C_IN(`RCL(DCL, C)),
	.D_IN(D),
	.shift_size(D_IN[10:8]),
	.shift_type(D_IN[12:11])
);
polyshift_r #(.word_width(8)) psr (
	.C_IN(`RCR(DCR, C)),
	.D_IN(D),
	.shift_size(D_IN[10:8]),
	.shift_type(D_IN[12:11])
);
endmodule