module main (
	input wire clk,
	input wire [31:0] D_IN,
	output wire [2 ** 5 - 1:0] D_OUT
);

//Fast adder
wire P;
wire G;
wire C_IN;
/*
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
//screening
screening_by_junior #(.word_width(8)) sbj (
	.C_IN(D_IN[0]),
	.IN(D_IN[8:1])
);
screening_by_senior #(.word_width(8)) sbs (
	.C_IN(D_IN[0]),
	.IN(D_IN[8:1])
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

*/

//adders
RCA_M #(.WORD_WIDTH(16)) rca_m (
	.c_i(C_IN),
	.a_i(D_IN[15:0]),
	.b_i(D_IN[31:16])
);
CLAA #(.WORD_WIDTH(16)) claa (
	.c_i(C_IN), 
	.a_i(D_IN[15:0]), 
	.b_i(D_IN[31:16])
);
CSA_S #(.UNIT_WIDTH(5), .WORD_WIDTH(15)) csa_s (
	.c_i(C_IN), 
	.a_i(D_IN[15:0]), 
	.b_i(D_IN[31:16])
);
//memory
counter #(.WORD_WIDTH(4)) cc (
	.clk_i(clk)
);
counter_forward #(.WORD_WIDTH(4)) ccsf (
	.clk_i(clk)
);
counter_backward #(.WORD_WIDTH(4)) ccsb (
	.clk_i(clk)
);
//shifts
polyshift_l_cf #(.WORD_WIDTH(8)) psl_cf (
	.cf_i(D_IN[0]),
	.shift_size_i(D_IN[3:1]),
	.word_i(D_IN[11:4])
);
polyshift_r_cf #(.WORD_WIDTH(8)) psr_cf (
	.cf_i(D_IN[0]),
	.shift_size_i(D_IN[3:1]),
	.word_i(D_IN[11:4])
);
wire [7:0] D = D_IN[7:0];
parameter C = 1'b0; 
wire [6:0] DCR = D[6:0];
wire [6:0] DCL = D[7:1];
polyshift_l #(.WORD_WIDTH(8)) psl (
	.c_i(`RCL(DCL, C)),
	.d_i(D),
	.shift_size_i(D_IN[10:8]),
	.shift_type_i(D_IN[12:11])
);
polyshift_r #(.WORD_WIDTH(8)) psr (
	.c_i(`RCR(DCR, C)),
	.d_i(D),
	.shift_size_i(D_IN[10:8]),
	.shift_type_i(D_IN[12:11])
);
//wire management
screening_by_junior #(.WORD_WIDTH(8)) sbj (
	.c_i(D_IN[0]),
	.in(D_IN[8:1])
);
screening_by_senior #(.WORD_WIDTH(8)) sbs (
	.c_i(D_IN[0]),
	.in(D_IN[8:1])
);
encoder #(.INPUT_WIDTH(5)) enc (
	.select_i(D_IN[4:0])
);
tree_decoder #(.OUTPUT_WIDTH(12)) tdec (
	.enable_i(D_IN[0]),
	.select_i(D_IN[4:1])
);
//comparator
fast_comparator #(.WORD_WIDTH(4)) fc (
	.a_i(D_IN[15:0]),
	.b_i(D_IN[31:16])
);


endmodule