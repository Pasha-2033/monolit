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
assing word_index = (l + r) / 2;
assing found = (check_word == needed_word);
wire l_assingment = word_index + 1;
wire r_assingment = word_index - 1;
always @(posedge clk) begin
	if (state) begin
		if (found | l_assingment > r_assingment) begin
			state <= 0;
		end else if (check_word > needed_word) begin
			r <= r_assingment;
		end else begin
			l <= l_assingment;
		end
	end else if (find) begin
		state <= 1;
		l <= 0;
		r <= word_length - 1;
	end
end
endmodule
module _fc_central_string #(
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
	output wire									prev_and_this_is_replaced,
	output wire									post_and_this_is_replaced,
	output wire									loading_prev,
	output wire									loading_post,
);
/*
str like struct, senior bits are address
*/
localparam size = address_size + data_size;
localparam data_end = data_size - 1;
localparam address_end = size - 1;
assign is_less = str[address_end:data_end + 1] < unique_str[address_end:data_end + 1];
assign is_bigger = str[address_end:data_end + 1] > unique_str[address_end:data_end + 1];
assing prev_and_this_is_replaced = prev_is_replaced | replace; 
assing post_and_this_is_replaced = post_is_replaced | replace; 
assing loading_prev = prev_is_bigger | post_and_this_is_replaced;
assing loading_post = post_is_less | prev_and_this_is_replaced;
wire [size * 4 - 1:0] possible_str = { post_str, prev_str, unique_str, str };
wire loading_unique = (~loading_prev & post_loading_this) | (~loading_post & prev_loading_this) | (replace & prev_is_less & post_is_bigger);
wire [1:0] mux_arg = { loading_prev, loading_post | loading_unique };
always @(posedge clk) begin
	str <= possible_str[mux_arg];
end
endmodule
module fast_cash #(
	parameter address_size,
	parameter data_size,
	parameter cash_length
) (
	
);
reg [address_size + data_size - 1:0][cash_length - 1:0] raw_memory;

endmodule