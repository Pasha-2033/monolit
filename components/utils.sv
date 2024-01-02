module bit_reverse #(
	parameter bit_width = 4
)(
	input wire	[bit_width - 1:0] in,
	output wire	[bit_width - 1:0] out
);
genvar i;
generate
	for(i = 0; i < bit_width; i++) begin: reverse
		assign out[i] = in[bit_width - i - 1];
	end
endgenerate
endmodule