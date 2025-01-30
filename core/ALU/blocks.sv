`ifndef STD_UTILS
	`include "utils.sv"
`endif
module SELECT #(
	parameter word_width
) (
	input wire	[1:0]				OP,
	input wire	[word_width - 1:0]	A,
	input wire	[word_width - 1:0]	B,
	input wire	[word_width - 1:0]	C,
	input wire	[word_width - 1:0]	D,
	output wire	[word_width - 1:0]	R
);
wire [3:0][word_width - 1:0] merger = {D, C, B, A};
assign R = merger[OP];
endmodule
module ARITHMETIC #(
	parameter word_width
) (
	input wire						CF_IN,
	input wire	[1:0]				OP,
	input wire	[word_width - 1:0]	A,
	input wire	[word_width - 1:0]	B,
	input wire	[word_width - 1:0]	NOT_B,
	output wire	[word_width - 1:0]	R,
	output wire						CF_OUT

);
wire [word_width - 1:0] pre_adder = OP[0] ? ~B : B;
wire [word_width - 1:0] post_adder;
assign {CF_OUT, post_adder} = A + pre_adder + (CF_IN & OP[1]);
assign R = OP[0] ? ~post_adder : post_adder;
endmodule
module LOGIC #(
	parameter word_width
) (
	input wire	[1:0]				OP,
	input wire	[word_width - 1:0]	A,
	input wire	[word_width - 1:0]	B,
	input wire	[word_width - 1:0]	NOT_B,
	output wire	[word_width - 1:0]	R
);
wire [word_width - 1:0] AND = A & B;
wire [word_width - 1:0] OR = A | B;
wire [word_width - 1:0] XOR = OR & ~AND;
wire [3:0][word_width - 1:0] merger = {XOR, OR, AND, NOT_B};
assign R = merger[OP];
endmodule
module CMP #(
	parameter word_width
) (
	input wire	[1:0]				OP,
	input wire	[word_width - 1:0]	A,
	input wire	[word_width - 1:0]	B,
	output wire	[word_width - 1:0]	R
);
wire above, below;
fast_comparator #(.word_width(word_width)) fc (
	.A(A),
	.B(B),
	.above(above),
	.below(below)
);
assign R = A;
assign CF_OUT = below & OP[0];
assign ZF_OUT = ~(above | below);
endmodule