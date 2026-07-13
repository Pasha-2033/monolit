/*
Provides:
	Gray to bin code converter
Dependencies:
	None
Parameters:
	WORD_WIDTH		- width of word to convert
Ports:
	data_i			- data to convert
	data_o			- converted data
Generation:
	TODO
Additional comments:
	None
*/
module gray_to_bin #(
	parameter WORD_WIDTH
) (
	input	wire [WORD_WIDTH - 1:0] data_i,
	output	wire [WORD_WIDTH - 1:0] data_o
);
assign data_o[WORD_WIDTH - 1] = data_i[WORD_WIDTH - 1];
genvar i;
generate
	for (i = 0; i < WORD_WIDTH - 1; ++i) begin : gray_to_bin_loop
		assign data_o[i] = data_o[i + 1] ^ data_i[i];
	end
endgenerate
endmodule