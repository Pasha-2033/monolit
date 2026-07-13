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
/*(* noprune *)*/ wire [WORD_WIDTH - 1:0] pre_above = a_i & ~b_i;
/*(* noprune *)*/ wire [WORD_WIDTH - 1:0] pre_below = ~a_i & b_i;
localparam TREE_LVL_NUM = $clog2(WORD_WIDTH);
localparam OVER_WIDTH = 2 ** TREE_LVL_NUM - WORD_WIDTH;
localparam REDUCTION = (OVER_WIDTH ? 1 : 0);
localparam TREE_LVL_LAST = TREE_LVL_NUM - REDUCTION + 1;
localparam ROOT_SIZE = 2 ** (TREE_LVL_NUM - REDUCTION);
`BIT_REVERSE_FUNCTION(reverse_bits, TREE_LVL_NUM - REDUCTION)
genvar i;
generate
	if (WORD_WIDTH > 1) begin
		/*(* noprune *)*/ wire [ROOT_SIZE - 1:0] above_root;
		/*(* noprune *)*/ wire [ROOT_SIZE - 1:0] below_root;
		/*(* noprune *)*/ wire [2 ** TREE_LVL_LAST - 2:0] above_tree;
		/*(* noprune *)*/ wire [2 ** TREE_LVL_LAST - 2:0] below_tree;
		assign above_o = above_tree[0];
		assign below_o = below_tree[0];
		for (i = 0; i < TREE_LVL_NUM - REDUCTION; ++i) begin : compare_lvl
			localparam SIZE = 2 ** i;
			assign above_tree[SIZE * 2 - 2-:SIZE] = above_tree[SIZE * 4 - 2-:SIZE] | (above_tree[SIZE * 2 - 1+:SIZE] & ~below_tree[SIZE * 4 - 2-:SIZE]);
			assign below_tree[SIZE * 2 - 2-:SIZE] = below_tree[SIZE * 4 - 2-:SIZE] | (~above_tree[SIZE * 4 - 2-:SIZE] & below_tree[SIZE * 2 - 1+:SIZE]);
		end
		for (i = 0; i < ROOT_SIZE; ++i) begin : root_sort
			assign above_tree[2 ** TREE_LVL_LAST - i - 2] = above_root[reverse_bits(ROOT_SIZE - i - 1)];
			assign below_tree[2 ** TREE_LVL_LAST - i - 2] = below_root[reverse_bits(ROOT_SIZE - i - 1)];
		end
		if (OVER_WIDTH) begin
			assign above_root[ROOT_SIZE - 1-:OVER_WIDTH] = pre_above[WORD_WIDTH - 1-:OVER_WIDTH];
			assign below_root[ROOT_SIZE - 1-:OVER_WIDTH] = pre_below[WORD_WIDTH - 1-:OVER_WIDTH];
			for (i = 0; i < ROOT_SIZE - OVER_WIDTH; ++i) begin : root_over_assignment
				localparam SHIFT = 2 * i;
				assign above_root[i] = pre_above[SHIFT + 1] | (pre_above[SHIFT] & ~pre_below[SHIFT + 1]);
				assign below_root[i] = pre_below[SHIFT + 1] | (~pre_above[SHIFT + 1] & pre_below[SHIFT]);
			end
		end else begin
			assign above_root = pre_above;
			assign below_root = pre_below;
		end	
	end else begin
		assign above_o = pre_above;
		assign below_o = pre_below;
	end
endgenerate
endmodule
/*
Provides:
	Сomparament with constant
Dependencies:
	NONE
Parameters:
	WORD_WIDTH - width of input word and constant
Ports:
	value	- value to compare
	equal	- is value == CONST_VALUE
Generation:
	TODO
Additional comments:
	Fully combinational
	Won`t overgenerate
	equal = ~(above | below)
*/
module const_comparator #(
	parameter WORD_WIDTH,
	parameter[WORD_WIDTH - 1:0] CONST_VALUE
) (
	input wire [WORD_WIDTH - 1:0] value,
	output wire equal
);
genvar i;
generate
	if (!CONST_VALUE) begin
		assign equal = ~|value;
	end else begin
		wire [WORD_WIDTH - 1:0] result;
		for (i = 0; i < WORD_WIDTH; ++i) begin : N_compare
			assign result[i] = CONST_VALUE[i] ? value[i] : ~value[i];
		end
		assign equal = &result;
	end
endgenerate
endmodule