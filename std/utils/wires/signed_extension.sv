module signed_extension #(
	parameter IN_WIDTH,
	parameter OUT_WIDTH
) (
	input	wire	[IN_WIDTH - 1:0]	in,
	output	wire	[OUT_WIDTH - 1:0]	out
);
assign out = {{(OUT_WIDTH - IN_WIDTH){in[IN_WIDTH - 1]}}, in[IN_WIDTH - 1:0]};
endmodule