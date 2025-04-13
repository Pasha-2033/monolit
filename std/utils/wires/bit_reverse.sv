/*
Provides:
	Word reversion bitwise (DCBA->ABCD).
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input and output words
Ports:
	data_i	- word to reverse
	data_o	- reversed word
Generation:
	Assigns junior bits to senior ones and senior bits to junior ones
Additional comments:
	Fully combinational
*/
module bit_reverse #(
	parameter WORD_WIDTH
) (
	input	wire [WORD_WIDTH - 1:0] data_i,
	output	wire [WORD_WIDTH - 1:0] data_o
);
genvar i;
generate
	for(i = 0; i < WORD_WIDTH; ++i) begin: reverse
		assign data_o[i] = data_i[WORD_WIDTH - i - 1];
	end
endgenerate
endmodule