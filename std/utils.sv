module bit_reverse #(
	parameter bit_width = 4
)(
	input	wire [bit_width - 1:0] in,
	output	wire [bit_width - 1:0] out
);
genvar i;
generate
	for(i = 0; i < bit_width; ++i) begin: reverse
		assign out[i] = in[bit_width - i - 1];
	end
endgenerate
endmodule
module fast_adder #(
	parameter cascade_size = 4,
	parameter bit_width = 4
) (
	input	wire					C_IN,
	input	wire [bit_width - 1:0]	A,
	input	wire [bit_width - 1:0]	B,
	output	wire [bit_width - 1:0]	R,
	output	wire					P,
	output	wire					G,
	output	wire					C_OUT
);
localparam cascade_num = bit_width / cascade_size;
wire [cascade_size - 1:0] PP;
wire [cascade_size - 1:0] PG;
wire [cascade_size - 1:0] GG;
wire [cascade_size:0] C;
assign C[0] = C_IN;
assign C_OUT = C[cascade_size];
assign P = &PP;
assign G = |GG;
genvar i;
genvar j;
generate
	if (cascade_num > 1) begin
		for(i = 0; i < cascade_size; ++i) begin: adder_cascade
			fast_adder #(.cascade_size(cascade_size), .bit_width(cascade_num)) child_fast_adder (
				.C_IN(C[i]),
				.A(A[(i + 1) * cascade_num - 1:i * cascade_num]),
				.B(B[(i + 1) * cascade_num - 1:i * cascade_num]),
				.R(R[(i + 1) * cascade_num - 1:i * cascade_num]),
				.P(PP[i]),
				.G(PG[i])
			);
		end
	end else begin
		for(i = 0; i < cascade_size; ++i) begin: bit_cascade
			//can be optimised by component num
			assign R[i] = A[i] ^ B[i] ^ C[i];
			assign PP[i] = A[i] | B[i];
			assign PG[i] = A[i] & B[i];
		end
	end
	for(i = 0; i < cascade_size; ++i) begin: signal_cascade
		if (i == cascade_size - 1) begin
			assign GG[i] = PG[i];
		end else begin
			assign GG[i] = PG[i] & (&PP[cascade_size - 1:i + 1]);
		end
		wire [i + 1:0] PRE_C;
		assign PRE_C[i + 1] = PG[i];
		assign PRE_C[0] = C_IN & (&PP[i:0]);
		for (j = 0; j < i; ++j) begin: c_cascade
			assign PRE_C[j + 1] = PG[j] & (&PP[i:j + 1]);
		end
		assign C[i + 1] = |PRE_C;
	end
endgenerate
endmodule
module counter_c #(
	parameter word_width = 8
) (
	input	wire					clk,
	input	wire					count,
	input	wire					load,
	input	wire					reset,
	input	wire [word_width - 1:0]	D_IN,
	output	reg  [word_width - 1:0]	D_OUT
);
wire [word_width - 1:0] count_flow;
wire [word_width - 1:0] load_flow;
wire inner_clk = clk & (count | load);
assign load_flow = {load_flow[word_width - 2:0] & ~D_OUT[word_width - 2:0], count & load};
assign count_flow = {count_flow[word_width - 2:0] & D_OUT[word_width - 2:0], ~load_flow[0]};
always @(posedge inner_clk) begin
	if (reset) begin
		D_OUT <= '0;
	end else begin
		D_OUT <= ~count & load ? D_IN : {D_OUT[word_width - 1:1] ^ (count_flow[word_width - 1:1] | load_flow[word_width - 1:1]), ~D_OUT[0]};
	end
end
endmodule
module decoder #(
	parameter input_width
) (
	input wire [input_width - 1:0] select,
	output wire [2 ** input_width - 1:0] out
);
wire [input_width - 1:0] inversed_select = ~select;
genvar i;
genvar j;
generate
	for (i = 0; i < 2 ** input_width; ++i) begin: decoded_output
		wire [input_width - 1:0] selection;
		for (j = 0; j < input_width; ++j) begin: selection_union
			assign selection[j] = i % (2 ** (j + 1)) >= 2 ** j ? select[j] : inversed_select[j];
		end
		assign out[i] = &selection;
	end
endgenerate
endmodule
module decoder_c #(
	parameter input_width
) (
	input wire enable,
	input wire [input_width - 1:0] select,
	output wire [2 ** input_width - 1:0] out
);
wire [2 ** input_width - 1:0] raw_decoded;
decoder #(.input_width(input_width)) dec (.select(select), .out(raw_decoded));
assign out = raw_decoded & {2 ** input_width{enable}};
endmodule