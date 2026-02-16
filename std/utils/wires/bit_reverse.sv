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
	//{<<{data_i}} is more readable, but not supported by everyone
	for(i = 0; i < WORD_WIDTH; ++i) begin: reverse
		assign data_o[i] = data_i[WORD_WIDTH - i - 1];
	end
endgenerate
endmodule
//virtual class with static function is more convenient to use, but not supported by everyone
`define BIT_REVERSE_FUNCTION(NAME, WORD_WIDTH)			\
function logic [(WORD_WIDTH) - 1:0] NAME;				\
	input logic [(WORD_WIDTH) - 1:0] in;				\
	integer i;											\
	for (i = 0; i < (WORD_WIDTH); ++i) begin : reverse	\
		NAME[i] = in[(WORD_WIDTH) - i - 1];				\
	end													\
endfunction