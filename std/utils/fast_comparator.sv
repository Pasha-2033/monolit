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




/////////////////////////////
//Old/non-working instances//
/////////////////////////////
module fast_comparator2 #(
    parameter WORD_WIDTH = 16
) (
    input   wire    [WORD_WIDTH - 1:0]  a_i,
    input   wire    [WORD_WIDTH - 1:0]  b_i,
    output  wire                        above_o,
    output  wire                        below_o
);

    // Расчет параметров дерева
    localparam TREE_LEVELS = $clog2(WORD_WIDTH);
    localparam TREE_SIZE   = 1 << TREE_LEVELS; // Ближайшая степень 2

    // Сетки уровней: [уровень][номер_узла]
    // lvl 0 - это входные биты, последний lvl - корень дерева
    wire [TREE_SIZE-1:0] above_lvl [0:TREE_LEVELS];
    wire [TREE_SIZE-1:0] below_lvl [0:TREE_LEVELS];

    genvar l, i;
    generate
        // --- УРОВЕНЬ 0: Листья (Подготовка бит) ---
        for (i = 0; i < TREE_SIZE; i = i + 1) begin : g_leaves
            if (i < WORD_WIDTH) begin : bit_map
                assign above_lvl[0][i] = a_i[i] & ~b_i[i];
                assign below_lvl[0][i] = ~a_i[i] & b_i[i];
            end else begin : padding
                // Заполнение для ширин, не кратных степени двойки
                assign above_lvl[0][i] = 1'b0;
                assign below_lvl[0][i] = 1'b0;
            end
        end

        // --- ПОСТРОЕНИЕ ДЕРЕВА ---
        for (l = 0; l < TREE_LEVELS; l = l + 1) begin : g_levels
            // На каждом следующем уровне узлов в 2 раза меньше
            localparam NODES = TREE_SIZE >> (l + 1);
            
            for (i = 0; i < NODES; i = i + 1) begin : g_nodes
                // Сравниваем пары: High (2*i + 1) и Low (2*i)
                // Результат выше, если выше High ИЛИ (High равны И выше Low)
                // "High равны" в нашей логике — это (~above_H & ~below_H)
                
                assign above_lvl[l+1][i] = above_lvl[l][2*i+1] | 
                                          (above_lvl[l][2*i] & ~below_lvl[l][2*i+1]);
                                          
                assign below_lvl[l+1][i] = below_lvl[l][2*i+1] | 
                                          (below_lvl[l][2*i] & ~above_lvl[l][2*i+1]);
            end
        end
    endgenerate

    // Корень дерева (уровень TREE_LEVELS, узел 0) — это финальный результат
    assign above_o = (WORD_WIDTH > 1) ? above_lvl[TREE_LEVELS][0] : (a_i & ~b_i);
    assign below_o = (WORD_WIDTH > 1) ? below_lvl[TREE_LEVELS][0] : (~a_i & b_i);
endmodule
module fast_comparator3 #(
	parameter WORD_WIDTH
) (
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,

	output	wire						above_o,
	output	wire						below_o
);
wire [WORD_WIDTH - 1:0] pre_above = a_i & ~b_i;
wire [WORD_WIDTH - 1:0] pre_below = ~a_i & b_i;
`BIT_REVERSE_FUNCTION(reverse_bits, $clog2(WORD_WIDTH))
genvar i;
generate
	if (WORD_WIDTH > 1) begin
		localparam TREE_LVL_NUM = $clog2(WORD_WIDTH);
		localparam TREE_LVL_LAST = TREE_LVL_NUM + 1;
		localparam OVER_WIDTH = 2 ** TREE_LVL_NUM - WORD_WIDTH;
		(* noprune *) wire [2 ** TREE_LVL_LAST - 2:0] above_tree;
		(* noprune *) wire [2 ** TREE_LVL_LAST - 2:0] below_tree;
		assign above_o = above_tree[0];
		assign below_o = below_tree[0];
		for (i = 0; i < TREE_LVL_NUM; ++i) begin : compare_lvl
			localparam SIZE = 2 ** i;
			assign above_tree[SIZE * 2 - 2-:SIZE] = above_tree[SIZE * 4 - 2-:SIZE] | (above_tree[SIZE * 2 - 1+:SIZE] & ~below_tree[SIZE * 4 - 2-:SIZE]);
			assign below_tree[SIZE * 2 - 2-:SIZE] = below_tree[SIZE * 4 - 2-:SIZE] | (~above_tree[SIZE * 4 - 2-:SIZE] & below_tree[SIZE * 2 - 1+:SIZE]);
		end
		for(i = 0; i < WORD_WIDTH / 2; ++i) begin : ddd2
			assign above_tree[2 ** TREE_LVL_LAST - i - 2] = pre_above[reverse_bits(WORD_WIDTH - i - 1)];
			assign above_tree[2 ** TREE_LVL_LAST - i - WORD_WIDTH / 2 - 2] = pre_above[reverse_bits(WORD_WIDTH - i - 1) - 1];

			assign below_tree[2 ** TREE_LVL_LAST - i - 2] = pre_below[reverse_bits(WORD_WIDTH - i - 1)];
			assign below_tree[2 ** TREE_LVL_LAST - i - WORD_WIDTH / 2 - 2] = pre_below[reverse_bits(WORD_WIDTH - i - 1) - 1];
		end

	end else begin
		assign above_o = pre_above;
		assign below_o = pre_below;
	end
endgenerate
endmodule
module fast_comparator4 #(
	parameter WORD_WIDTH
) (
	input	wire	[WORD_WIDTH - 1:0]	a_i,
	input	wire	[WORD_WIDTH - 1:0]	b_i,

	output	wire						above_o,
	output	wire						below_o
);
// precompare lvl (prepares for tree and valid only if WORD_WIDTH = 1)
(* noprune *) wire [WORD_WIDTH - 1:0] pre_above = a_i & ~b_i;
(* noprune *) wire [WORD_WIDTH - 1:0] pre_below = ~a_i & b_i;
localparam TREE_LVL_NUM = $clog2(WORD_WIDTH);
localparam OVER_WIDTH = 2 ** TREE_LVL_NUM - WORD_WIDTH;
localparam REDUCTION = (OVER_WIDTH ? 1 : 0);
localparam TREE_LVL_LAST = TREE_LVL_NUM - REDUCTION + 1;
localparam ROOT_SIZE = 2 ** TREE_LVL_NUM / 2;
`BIT_REVERSE_FUNCTION(reverse_bits, $clog2(WORD_WIDTH) - 1)
genvar i;
generate
	if (WORD_WIDTH > 1) begin
		(* noprune *) wire [ROOT_SIZE - 1:0] above_root;
		(* noprune *) wire [ROOT_SIZE - 1:0] below_root;
		(* noprune *) wire [2 ** TREE_LVL_LAST - 2:0] above_tree;
		(* noprune *) wire [2 ** TREE_LVL_LAST - 2:0] below_tree;
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
		end
		for (i = 0; i < ROOT_SIZE - OVER_WIDTH; ++i) begin : root_over_assignment
			localparam SHIFT = 2 * i;
			assign above_root[i] = pre_above[SHIFT + 1] | (pre_above[SHIFT] & ~pre_below[SHIFT + 1]);
			assign below_root[i] = pre_below[SHIFT + 1] | (~pre_above[SHIFT + 1] & pre_below[SHIFT]);
		end
	end else begin
		// assign output if WORD_WIDTH = 1
		assign above_o = pre_above;
		assign below_o = pre_below;
	end
endgenerate
endmodule