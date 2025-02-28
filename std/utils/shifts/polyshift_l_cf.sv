/*
Provides:
	All left shift carry flag
Dependencies:
	bit_reverse
	polyshift_r_cf
Parameters:
	WORD_WIDTH		- word width of polyshift_l
Ports:
	cf_i			- carry flag (default) input
	shift_size_i	- shift_size_i of polyshift_l
	word_i			- senior bits of polyshift_l word input
	cf_o			- carry flag output
Generation:
	NONE
Additional comments:
	Fully combinational
*/
module polyshift_l_cf #(
	parameter WORD_WIDTH
) (
	input	wire								cf_i,

	input	wire	[$clog2(WORD_WIDTH) - 1:0]	shift_size_i,
	input	wire	[WORD_WIDTH - 2:0]			word_i,

	output	wire								cf_o
);
wire [WORD_WIDTH - 2:0] word_i_reversed;

bit_reverse #(.WORD_WIDTH(WORD_WIDTH)) reverse_in (
	.in				(word_i),
	.out			(word_i_reversed)
);

polyshift_r_cf #(.WORD_WIDTH(WORD_WIDTH)) psr_cf (
	.cf_i			(cf_i),
	.shift_size_i	(shift_size_i),
	.word_i			(word_i_reversed),
	.cf_o			(cf_o)
);
endmodule