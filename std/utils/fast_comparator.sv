/*
Provides:
	Binary tree like comparator
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input words
Ports:
	a_i		- A operand
	b_i 	- B operand
	above_o	- bool state: A > B
	below_o - bool state: A < B 
Generation:
	TODO
Additional comments:
	Fully combinational
	Won`t overgenerate
	equal = ~(above | below)
*/
module fast_comparator #(
	parameter WORD_WIDTH
) (
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,

	output	wire						above_o,
	output	wire						below_o
);
// precompare lvl (prepares for tree and valid only if WORD_WIDTH = 1)
wire [WORD_WIDTH - 1:0] pre_above = a_i & ~b_i;
wire [WORD_WIDTH - 1:0] pre_below = ~a_i & b_i;

genvar i;
generate
	if (WORD_WIDTH > 1) begin
		// calc tree SIZE
		localparam I_LIMIT	= $clog2(WORD_WIDTH) - 1;
		localparam CV		= 2 ** (I_LIMIT + 1) - WORD_WIDTH;

		// provide tree wires (2 ** n - 1)
		wire [2 ** (I_LIMIT + 1) - 2:0] above_tree;
		wire [2 ** (I_LIMIT + 1) - 2:0] below_tree;

		// assign tree to output
		assign above_o = above_tree[0];
		assign below_o = below_tree[0];
		
		// create tree
		for (i = 0; i < I_LIMIT; ++i) begin : compare_lvl
			localparam SIZE = 2 ** i;			//size of block
			localparam SENIOR = SIZE * 2 - 1;	//senior start address
			localparam JUNIOR = SENIOR * 2;		//junior end address
			assign above_tree[SIZE - 1+:SIZE] = above_tree[JUNIOR-:SIZE] | (above_tree[SENIOR+:SIZE] & ~below_tree[JUNIOR-:SIZE]);
			assign below_tree[SIZE - 1+:SIZE] = below_tree[JUNIOR-:SIZE] | (~above_tree[JUNIOR-:SIZE] & below_tree[SENIOR+:SIZE]);
		end

		// assign pre_above and pre_below to tree
		localparam SIZE = 2 ** I_LIMIT;
		assign above_tree[SIZE - 1+:SIZE - CV] = pre_above[WORD_WIDTH - CV - 1-:SIZE - CV] | (pre_above[SIZE - 1:0] & ~pre_below[WORD_WIDTH - CV - 1-:SIZE - CV]);
		assign below_tree[SIZE - 1+:SIZE - CV] = pre_below[WORD_WIDTH - CV - 1-:SIZE - CV] | (~pre_above[WORD_WIDTH - CV - 1-:SIZE - CV] & pre_below[SIZE - 1:0]);
		if (CV) begin
			assign above_tree[2 ** (I_LIMIT + 1) - 2-:CV] = pre_above[WORD_WIDTH - 1-:CV];
			assign below_tree[2 ** (I_LIMIT + 1) - 2-:CV] = pre_below[WORD_WIDTH - 1-:CV];
		end
	end
	else begin
		// assign output if WORD_WIDTH = 1
		assign above_o = pre_above;
		assign below_o = pre_below;
	end
endgenerate
endmodule