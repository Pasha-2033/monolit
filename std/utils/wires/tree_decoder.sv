/*
Provides:
	MUX tree decoder
Dependencies:
	NONE
Parameters:
	OUTPUT_WIDTH	- width of operand and result
Ports:
	enable_i		- enable output
	select_i_i		- select_i decoding value
	out				- decoding result
Generation:
	Creates MUX tree layer by layer
Additional comments:
	Fully combinational
	Supports non 2^n outputs, so it won`t overgenerate
*/
module tree_decoder #(
	parameter OUTPUT_WIDTH
) (
	input	wire										enable_i,
	input	wire [$clog2(`max(OUTPUT_WIDTH, 2)) - 1:0]	select_i,

	output	wire [OUTPUT_WIDTH - 1:0]					out
);
genvar i;
generate
	if (OUTPUT_WIDTH > 1) begin
		// provide tree wires (2 ** n - 1)
		localparam INPUT_WIDTH = $clog2(OUTPUT_WIDTH);
		wire [2 ** (INPUT_WIDTH) - 2:0] mux_tree;
		assign mux_tree[0] = enable_i;

		for (i = 1; i < INPUT_WIDTH; ++i) begin: main_tree
			localparam SIZE = 2 ** (i - 1);
			assign mux_tree[2 ** i - 1+:2 ** i] = {select_i[i - 1] ? mux_tree[2 ** i - 2-:SIZE] : '0, select_i[i - 1] ? '0 : mux_tree[SIZE - 1+:SIZE]};
		end

		localparam SIZE = 2 ** (INPUT_WIDTH - 1);
		assign out = {select_i[INPUT_WIDTH - 1] ? mux_tree[SIZE - 1+:OUTPUT_WIDTH - SIZE] : '0, select_i[INPUT_WIDTH - 1] ? '0 : mux_tree[SIZE - 1+:SIZE]};
	end
	else begin
		assign out = select_i & enable_i;
	end
endgenerate
endmodule