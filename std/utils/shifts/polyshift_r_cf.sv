/*
Provides:
	All right shift carry flag
Dependencies:
	NONE
Parameters:
	WORD_WIDTH		- word width of polyshift_r
Ports:
	cf_i			- carry flag (default) input
	shift_size_i	- shift_size_i of polyshift_r
	data_i			- junior bits of polyshift_r word input
	cf_o			- carry flag output
Generation:
	NONE
Additional comments:
	Fully combinational
*/
module polyshift_r_cf #(
	parameter WORD_WIDTH
) (
	input	wire								cf_i,

	input	wire	[$clog2(WORD_WIDTH) - 1:0]	shift_size_i,
	input	wire	[WORD_WIDTH - 2:0]			data_i,

	output	wire								cf_o
);
wire	[WORD_WIDTH - 1:0]	selection	= { data_i, cf_i };
assign 						cf_o		= selection[shift_size_i];
endmodule