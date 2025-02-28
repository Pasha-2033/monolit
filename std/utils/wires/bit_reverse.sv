/*
Provides:
	Word reversion bitwise (DCBA->ABCD).
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	in	- word to reverse
	out	- reversed word
Generation:
	Assigns junior bits to senior ones and senior bits to junior ones
Additional comments:
	Fully combinational
*/
module bit_reverse #(
	parameter WORD_WIDTH
) (
	input	wire [WORD_WIDTH - 1:0] in,
	output	wire [WORD_WIDTH - 1:0] out
);
genvar i;
generate
	for(i = 0; i < WORD_WIDTH; ++i) begin: reverse
		assign out[i] = in[WORD_WIDTH - i - 1];
	end
endgenerate
endmodule