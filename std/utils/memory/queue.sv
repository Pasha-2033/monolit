//DO NOT CAUSE OVERFLOW/UNDERFLOW!!!
module sync_queue_bin #(
	parameter WORD_WIDTH,
	parameter ADDRESS_WIDTH
) (
	input	wire							clk_i,
	input	wire							arst_i,
	input	wire							push_i,
	input	wire							pop_i,
	input	wire	[WORD_WIDTH - 1:0]		data_i,
	output	wire	[WORD_WIDTH - 1:0]		data_o,
	output	wire	[ADDRESS_WIDTH - 1:0]	point,
	output	wire							is_empty,
	output	wire							is_full
);
localparam LENGTH = 2 ** ADDRESS_WIDTH;
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
wire [LENGTH - 1:0][WORD_WIDTH - 1:0] shifted_output;
counter #(.WORD_WIDTH(ADDRESS_WIDTH)) pointer (
	.clk_i(clk_i),
	.count_i(push_i ^ pop_i),
	.load_i(~push_i & pop_i),
	.arst_i(arst_i),
	.data_i('0),
	.data_o(point),
	.will_overflow_o(is_full),
	.will_underflow_o(is_empty)
);
assign shifted_output = {data[LENGTH - 2:0], data[LENGTH - 1]};
//if we will push & pop at the same time with 0 cap - we will get data[LENGTH - 1], which is not initialized
//if we will push & pop at the sane time with !0 cap - we will shift data register and get correct shifted_output[point] result
assign data_o = is_empty ? data_i : shifted_output[point];
integer i;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
	end else if (push_i) begin
		data <= {data[LENGTH - 2:0], data_i};
	end
end
endmodule
//DO NOT CAUSE OVERFLOW/UNDERFLOW!!!
//if empty - will send 'z, can be avoided by (is_empty & ~(push_i & pop_i)) ? '0 : 'z
module sync_queue_tri #(
	parameter WORD_WIDTH,
	parameter LENGTH
) (
	input	wire						clk_i,
	input	wire						arst_i,
	input	wire						push_i,
	input	wire						pop_i,
	input	wire	[WORD_WIDTH - 1:0]	data_i,
	output	wire	[WORD_WIDTH - 1:0]	data_o,
	output	wire						is_empty,
	output	wire						is_full
);
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
reg [LENGTH:0] filled;

genvar i;
generate
	for (i = 0; i < LENGTH; ++i) begin : output_collector
		assign data_o = filled[i + 1] ? data[i] : 'z;
	end
endgenerate

always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
		filled[LENGTH:1] <= '0;
		filled[0] <= '1;
	end else begin
		if (pop_i) begin
			if (push_i) begin
				data <= {data[LENGTH - 2:0], data_i};
			end else begin
				filled[LENGTH:1] <= {1'b0, filled[LENGTH:2]};
				filled[0] <= filled[1] ? '1 : filled[0];
			end
		end else if (push_i) begin
			data <= {data[LENGTH - 2:0], data_i};
			filled[LENGTH - 1:0] <= {filled[LENGTH - 2:0], 1'b0};
			filled[LENGTH] <= filled[LENGTH] ? '1 : filled[LENGTH - 1];
		end
	end
end
//OUTDATED (CODE ABOVE IS BETTER IF LENGTH IS BIGGER)
/*
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
reg [LENGTH - 1:0] filled;
wire [LENGTH - 1:0] output_allowed;
assign output_allowed = {filled[LENGTH - 1], filled[LENGTH - 2:0] & ~filled[LENGTH - 1:1]};
assign is_empty = ~filled[0];
assign is_full = filled[LENGTH - 1];
genvar i;
generate
	for (i = 0; i < LENGTH; ++i) begin : output_collector
		assign data_o = output_allowed[i] ? data[i] : 'z;
	end
endgenerate
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
		filled <= '0;
	end else begin
		if (pop_i) begin
			if (push_i) begin
				data <= {data[LENGTH - 2:0], data_i};
			end else begin
				filled <= {1'b0, filled[LENGTH - 1:1]};
			end
		end else if (push_i) begin
			filled <= {filled[LENGTH - 2:0], 1'b1};
			data <= {data[LENGTH - 2:0], data_i};
		end
	end
end
*/
endmodule