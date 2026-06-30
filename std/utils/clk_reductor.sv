module const_clk_reductor #(
	parameter REDUCTION
) (
	input	wire	arst_i, //for init & clk block
	input	wire	clk_i,
	output	wire	clk_o
);
localparam SIZE = $clog2(REDUCTION);
generate
	if (REDUCTION == 1) begin
		assign clk_o = clk_i;
	end else if (`IS_2POW(REDUCTION)) begin
		wire [SIZE - 1:0] reductor_data;
		counter_forward #(.WORD_WIDTH(SIZE)) reductor (
			.clk_i(clk_i),
			.action_i('0),
			.arst_i(arst_i),
			.data_o(reductor_data)
		);
		assign clk_o = reductor_data[SIZE - 1];
	end else begin
		reg clk_handler;
		wire hit;
		wire [SIZE - 1:0] reductor_data;
		assign clk_o = clk_handler;
		counter_forward #(.WORD_WIDTH(SIZE)) reductor (
			.clk_i(clk_i),
			.arst_i(arst_i),
			.action_i(hit),
			.data_i('0),
			.data_o(reductor_data)
		);
		const_comparator #(.WORD_WIDTH(SIZE), .CONST_VALUE(REDUCTION - 1)) low_const_cmp (
			.value(reductor_data),
			.equal(hit)
		);
		always_ff @(negedge hit or posedge arst_i) begin
			if (arst_i) begin
				clk_handler <= '0;
			end else begin
				clk_handler <= ~clk_handler;
			end
		end
	end
endgenerate
endmodule
module dyn_clk_reductor #(
	parameter WORD_WIDTH
) (
	input	[WORD_WIDTH - 1:0]	value_i,
	input	wire				arst_i, //for init & clk block
	input	wire				clk_i,
	output	wire				clk_o
);
generate
	if (WORD_WIDTH == 1) begin
		assign clk_o = clk_i;
	end else begin
		reg clk_handler;
		wire hit;
		wire [WORD_WIDTH - 1:0] reductor_data;
		assign clk_o = clk_handler;
		counter_forward #(.WORD_WIDTH(WORD_WIDTH)) reductor (
			.clk_i(clk_i),
			.arst_i(arst_i),
			.action_i(hit),
			.data_i('0),
			.data_o(reductor_data)
		);
		fast_comparator #(.WORD_WIDTH(WORD_WIDTH)) cmp (
			.a_i(reductor_data),
			.b_i(value_i),
			.below_o(hit)
		);
		always_ff @(negedge hit or posedge arst_i) begin
			if (arst_i) begin
				clk_handler <= '0;
			end else begin
				clk_handler <= ~clk_handler;
			end
		end
	end
endgenerate
endmodule