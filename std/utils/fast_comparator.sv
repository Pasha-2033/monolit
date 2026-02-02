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
		localparam TREE_LVL_NUM = $clog2(WORD_WIDTH);
		localparam TREE_LVL_LAST = TREE_LVL_NUM + 1;
		localparam OVER_WIDTH = 2 ** TREE_LVL_NUM - WORD_WIDTH;
		wire [2 ** TREE_LVL_LAST - 2:0] above_tree;
		wire [2 ** TREE_LVL_LAST - 2:0] below_tree;
		assign above_o = above_tree[0];
		assign below_o = below_tree[0];
		for (i = 0; i < TREE_LVL_NUM; ++i) begin : compare_lvl
			localparam SIZE = 2 ** i;
			assign above_tree[SIZE * 2 - 2-:SIZE] = above_tree[SIZE * 4 - 2-:SIZE] | (above_tree[SIZE * 2 - 1+:SIZE] & ~below_tree[SIZE * 4 - 2-:SIZE]);
			assign below_tree[SIZE * 2 - 2-:SIZE] = below_tree[SIZE * 4 - 2-:SIZE] | (~above_tree[SIZE * 4 - 2-:SIZE] & below_tree[SIZE * 2 - 1+:SIZE]);
		end
		assign above_tree[2 ** TREE_LVL_LAST - 2-:WORD_WIDTH - OVER_WIDTH * 2] = pre_above[WORD_WIDTH - 1-:WORD_WIDTH - OVER_WIDTH * 2];
		assign below_tree[2 ** TREE_LVL_LAST - 2-:WORD_WIDTH - OVER_WIDTH * 2] = pre_below[WORD_WIDTH - 1-:WORD_WIDTH - OVER_WIDTH * 2];
		if (OVER_WIDTH) begin
			assign above_tree[2 ** TREE_LVL_LAST - WORD_WIDTH - 2+:OVER_WIDTH] = pre_above[OVER_WIDTH+:OVER_WIDTH] | (pre_above[0+:OVER_WIDTH] & ~pre_below[OVER_WIDTH+:OVER_WIDTH]);
			assign below_tree[2 ** TREE_LVL_LAST - WORD_WIDTH - 2+:OVER_WIDTH] = pre_below[OVER_WIDTH+:OVER_WIDTH] | (~pre_above[OVER_WIDTH+:OVER_WIDTH] & pre_below[0+:OVER_WIDTH]);
		end
	end
	else begin
		// assign output if WORD_WIDTH = 1
		assign above_o = pre_above;
		assign below_o = pre_below;
	end
endgenerate
endmodule