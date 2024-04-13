module _bin_searcher #(
	parameter word_width,
	parameter word_length
) (
	input wire								clk,
	input wire								find,
	input wire	[word_width - 1:0]			needed_word,
	input wire	[word_width - 1:0]			check_word,
	output wire [$clog2(word_length) - 1:0]	word_index,
	output wire								found,
	output reg								state
);
reg [$clog2(word_length) - 1:0] l;
reg [$clog2(word_length) - 1:0] r;
assign word_index = (l + r) / 2;
assign found = (check_word == needed_word);
wire l_assignment = word_index + 1;
wire r_assignment = word_index - 1;
always @(posedge clk) begin
	if (state) begin
		if (found | l_assignment > r_assignment) begin
			state <= 0;
		end else if (check_word > needed_word) begin
			r <= r_assignment;
		end else begin
			l <= l_assignment;
		end
	end else if (find) begin
		state <= 1;
		l <= 0;
		r <= word_length - 1;
	end
end
endmodule
module _fbsoc_central_string #(
	parameter address_size,
	parameter data_size
) (
	input wire									clk,
	input wire									replace,
	input wire									prev_is_less,
	input wire									prev_is_bigger,
	input wire									prev_is_replaced,
	input wire									prev_loading_this,
	input wire									post_is_less,
	input wire									post_is_bigger,
	input wire									post_is_replaced,
	input wire									post_loading_this,
	input wire [address_size + data_size - 1:0]	unique_str,
	input wire [address_size + data_size - 1:0]	prev_str,
	input wire [address_size + data_size - 1:0]	post_str,
	output reg [address_size + data_size - 1:0]	str,
	output wire									is_less,
	output wire									is_bigger,
	output wire									prev_or_this_is_replaced,
	output wire									post_or_this_is_replaced,
	output wire									loading_prev,
	output wire									loading_post
);
localparam size = address_size + data_size;
localparam data_end = data_size - 1;
localparam address_end = size - 1;
//NOTE: str like struct, senior bits are address
assign is_less = str[address_end:data_end + 1] < unique_str[address_end:data_end + 1];	//not shure, need checks, but NOT(is_bigger) will reduse comparators size
assign is_bigger = str[address_end:data_end + 1] > unique_str[address_end:data_end + 1];
assign prev_or_this_is_replaced = prev_is_replaced | replace; 
assign post_or_this_is_replaced = post_is_replaced | replace; 
assign loading_prev = prev_is_bigger | post_or_this_is_replaced;
assign loading_post = post_is_less | prev_or_this_is_replaced;
wire [size * 4 - 1:0] possible_str = { post_str, prev_str, unique_str, str };
wire loading_unique = (~loading_prev & post_loading_this) | (~loading_post & prev_loading_this) | (replace & prev_is_less & post_is_bigger);
wire [1:0] mux_arg = { loading_prev, loading_post | loading_unique };
always @(posedge clk) begin
	str <= possible_str[mux_arg];
end
endmodule
module _fbsoc_string_container #(
	parameter address_size,
	parameter data_size,
	parameter cash_length
) (
	input wire											clk,
	input wire											write,
	input wire [$clog2(cash_length) - 1:0]				index,
	input wire [address_size + data_size - 1:0]			D_IN,
	output wire [address_size + data_size - 1:0]		D_OUT
);
localparam size = address_size + data_size;
//WARNING: container supports only 5+ cash_length
//NOTE: its unsufficient to use this complex container for small ammount of memory
//NOTE: address is recognised as order forming data, any metadata may cause problems, use it in data section
wire [cash_length - 1:0] reg_selection;
decoder_c #(.input_width($clog2(cash_length))) dec (.enable(write), .select(index), .out(reg_selection));
reg [3:0][size - 1:0] framing_memory;
wire [cash_length - 1:0][size - 1:0] all_str;
assign all_str[1:0] = framing_memory[1:0];
assign all_str[cash_length - 1:cash_length - 2] = framing_memory[3:2];
assign D_OUT = all_str[index];
wire [cash_length - 1:0] all_str_less;						//[1:0] by first two framing regs, [cash_length - 1:cash_length - 2] by lsat two framing regs
wire [cash_length - 1:0] all_str_bigger;					//[1:0] by first two framing regs, [cash_length - 1:cash_length - 2] by lsat two framing regs
wire [cash_length - 3:0] all_str_prev_or_this_is_replaced;	//[0] is by second reg, [cash_length - 3] is by prelast reg
wire [cash_length - 3:0] all_str_post_or_this_is_replaced;	//[0] is by second reg, [cash_length - 3] is by prelast reg
wire [cash_length - 3:0] all_str_loading_prev;				//[0] is by second reg, [cash_length - 3] is by prelast reg
wire [cash_length - 3:0] all_str_loading_post;				//[0] is by second reg, [cash_length - 3] is by prelast reg
assign all_str_less[0] = all_str[0][size - 1:data_size] < D_IN[size - 1:data_size]; //not shure, need checks, but NOT(is_bigger) will reduse comparators size
assign all_str_bigger[0] = all_str[0][size - 1:data_size] > D_IN[size - 1:data_size];
assign all_str_less[1] = all_str[1][size - 1:data_size] < D_IN[size - 1:data_size]; //not shure, need checks, but NOT(is_bigger) will reduse comparators size
assign all_str_bigger[1] = all_str[1][size - 1:data_size] > D_IN[size - 1:data_size];
assign all_str_less[cash_length - 2] = all_str[cash_length - 2][size - 1:data_size] < D_IN[size - 1:data_size]; //not shure, need checks, but NOT(is_bigger) will reduse comparators size
assign all_str_bigger[cash_length - 2] = all_str[cash_length - 2][size - 1:data_size] > D_IN[size - 1:data_size];
assign all_str_less[cash_length - 1] = all_str[cash_length - 1][size - 1:data_size] < D_IN[size - 1:data_size]; //not shure, need checks, but NOT(is_bigger) will reduse comparators size
assign all_str_bigger[cash_length - 1] = all_str[cash_length - 1][size - 1:data_size] > D_IN[size - 1:data_size];
assign all_str_prev_or_this_is_replaced[0] = |reg_selection[1:0];
assign all_str_prev_or_this_is_replaced[cash_length - 3] = all_str_prev_or_this_is_replaced[cash_length - 4] | reg_selection[size - 2];
assign all_str_post_or_this_is_replaced[0] = all_str_post_or_this_is_replaced[1] | reg_selection[1];
assign all_str_post_or_this_is_replaced[cash_length - 3] = |reg_selection[size - 1:size - 2];
assign all_str_loading_prev[0] = all_str_bigger[0] & all_str_post_or_this_is_replaced[0];
assign all_str_loading_prev[cash_length - 3] = all_str_bigger[cash_length - 3] & all_str_post_or_this_is_replaced[cash_length - 3];
assign all_str_loading_post[0] = all_str_less[2] & all_str_prev_or_this_is_replaced[0];
assign all_str_loading_post[cash_length - 3] = all_str_less[cash_length - 1] & all_str_prev_or_this_is_replaced[cash_length - 3];
wire first_reg_en = reg_selection[0] | all_str_loading_prev[0];
wire last_reg_en = reg_selection[cash_length - 1] | all_str_loading_post[cash_length - 3];
wire [3:0][size - 1:0] second_reg_variants;
assign second_reg_variants[0] = framing_memory[1];
assign second_reg_variants[1] = D_IN;
assign second_reg_variants[2] = framing_memory[0];
assign second_reg_variants[3] = all_str[2];
wire [3:0][size - 1:0] prelast_reg_variants;
assign prelast_reg_variants[0] = framing_memory[2];
assign prelast_reg_variants[1] = D_IN;
assign prelast_reg_variants[2] = all_str[cash_length - 3];
assign prelast_reg_variants[3] = framing_memory[3];
wire second_reg_loading_unique = (all_str_less[1] & first_reg_en & ~all_str_loading_post[0]) | (~all_str_loading_prev[0] & all_str_loading_prev[1]) | (all_str_less[0] & all_str_bigger[2] & reg_selection[1]);
wire [1:0] second_reg_mux = { all_str_loading_prev[0], second_reg_loading_unique | all_str_loading_post[0] };
wire prelast_reg_loading_unique = (all_str_loading_post[cash_length - 4] & ~all_str_loading_post[cash_length - 3]) | (~all_str_loading_prev[cash_length - 3] & last_reg_en & all_str_bigger[cash_length - 2]) | (all_str_less[cash_length - 3] & reg_selection[cash_length - 2] & all_str_bigger[cash_length - 1]);
wire [1:0] prelast_reg_mux = { all_str_loading_prev[cash_length - 3], prelast_reg_loading_unique | all_str_loading_post[cash_length - 3] };
//to do framing_memory
genvar i;
generate
	for (i = 2; i < cash_length - 2; ++i) begin: fbsoc_central_str
		_fbsoc_central_string #(.address_size(address_size), .data_size(data_size)) central_str (
			.clk(clk),
			.replace(reg_selection[i]),
			.prev_is_less(all_str_less[i - 1]),
			.prev_is_bigger(all_str_bigger[i - 1]),
			.prev_is_replaced(all_str_prev_or_this_is_replaced[i - 2]),
			.prev_loading_this(all_str_loading_post[i - 2]),
			.post_is_less(all_str_less[i + 1]),
			.post_is_bigger(all_str_bigger[i + 1]),
			.post_is_replaced(all_str_post_or_this_is_replaced[i]),
			.post_loading_this(all_str_loading_prev[i]),
			.prev_str(all_str[i - 1]),
			.post_str(all_str[i + 1]),
			.unique_str(D_IN),
			.str(all_str[i]),
			.is_less(all_str_less[i]),
			.is_bigger(all_str_bigger[i]),
			.prev_or_this_is_replaced(all_str_prev_or_this_is_replaced[i - 1]),
			.post_or_this_is_replaced(all_str_post_or_this_is_replaced[i - 1]),
			.loading_prev(all_str_loading_prev[i - 1]),
			.loading_post(all_str_loading_post[i - 1])
		);
	end
endgenerate
always @(posedge clk) begin
	if (first_reg_en) begin
		framing_memory[0] <= all_str_less[1] ? framing_memory[1] : D_IN;
	end
	if (last_reg_en) begin
		framing_memory[3] <= all_str_bigger[cash_length - 2] ? D_IN : framing_memory[2];
	end
	framing_memory[1] <= second_reg_variants[second_reg_mux];
	framing_memory[2] <= prelast_reg_variants[prelast_reg_mux];
end
endmodule




//to do
module fast_binary_search_order_cash #(
	parameter address_size,
	parameter data_size,
	parameter cash_length
) (
	input wire											clk,
	input wire [address_size + data_size - 1:0]			D_IN,
	output wire [address_size + data_size - 1:0]		D_OUT
);

endmodule