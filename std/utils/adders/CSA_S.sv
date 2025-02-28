/*
Provides:
	Static size carry select adder
Dependencies:
	_CSA_U
Parameters:
	UNIT_WIDTH -
	WORD_WIDTH - width of input and output words
Ports:
	c_i		- carry in
	a_i		- A operand
	b_i 	- B operand
	r_o 	- result
	c_o		- carry out
Generation:
	if WORD_WIDTH ∈ [1;2]		- create small RCA_M
	if WORD_WIDTH % UNIT_WIDTH	- create blocks and junior (redused block) _CSA_U
	if WORD_WIDTH / UNIT_WIDTH	- create UNIT_WIDTH (non redused blocks) _CSA_U
Additional comments:
	Fully combinational
*/
module CSA_S #(
	parameter UNIT_WIDTH,
	parameter WORD_WIDTH
) (
	input	wire					c_i,

	input	wire [WORD_WIDTH - 1:0]	a_i,
	input	wire [WORD_WIDTH - 1:0]	b_i,
	output	wire [WORD_WIDTH - 1:0]	r_o,

	output	wire 					c_o
);
localparam FULL_UNITS_NUM = WORD_WIDTH / UNIT_WIDTH;
localparam JUNIOR_WORD_WIDTH = WORD_WIDTH % UNIT_WIDTH;
wire [FULL_UNITS_NUM:0] all_c;
assign c_o = all_c[FULL_UNITS_NUM];

generate
	if (JUNIOR_WORD_WIDTH > 2) begin
		_CSA_U #(.WORD_WIDTH(JUNIOR_WORD_WIDTH)) junior_adder (
			.c_i(c_i),
			.a_i(a_i[JUNIOR_WORD_WIDTH - 1:0]),
			.b_i(b_i[JUNIOR_WORD_WIDTH - 1:0]),
			.r_o(r_o[JUNIOR_WORD_WIDTH - 1:0]),
			.c_o(all_c[0])
		);
	end	
	else if (JUNIOR_WORD_WIDTH) begin
		RCA_M #(.WORD_WIDTH(JUNIOR_WORD_WIDTH)) junior_adder (
			.c_i(c_i),
			.a_i(a_i[JUNIOR_WORD_WIDTH - 1:0]),
			.b_i(b_i[JUNIOR_WORD_WIDTH - 1:0]),
			.r_o(r_o[JUNIOR_WORD_WIDTH - 1:0]),
			.c_o(all_c[0])
		);
	end 
	else begin
		assign all_c[0] = c_i;
	end
	if (FULL_UNITS_NUM) begin
		_CSA_U #(.WORD_WIDTH(UNIT_WIDTH)) adder [FULL_UNITS_NUM - 1:0] (
			.c_i(all_c[FULL_UNITS_NUM - 1:0]),
			.a_i(a_i[WORD_WIDTH - 1:JUNIOR_WORD_WIDTH]),
			.b_i(b_i[WORD_WIDTH - 1:JUNIOR_WORD_WIDTH]),
			.r_o(r_o[WORD_WIDTH - 1:JUNIOR_WORD_WIDTH]),
			.c_o(all_c[FULL_UNITS_NUM:1])
		);
	end
endgenerate
endmodule