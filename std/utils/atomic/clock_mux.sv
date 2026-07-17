/*
Provides:
	Clock mux
Dependencies:
	tree_decoder
Parameters:
	ADDRESS_WIDTH	- how many clocks can be attached
Ports:
	arst_i		- asynchronous reset
	select_i	- clock domain selection
	clocks_i	- domain clock
	clock_o		- clock output
Generation:
	Uses en_reg as allowed for clock
	Uses set_enable as blocker for posedge of active clocks
Additional comments:
	Will provide glitch safely clock selection (negedge)
*/
module clock_mux #(
	parameter ADDRESS_WIDTH
) (
	input	wire								arst_i,
	input	wire	[ADDRESS_WIDTH - 1:0]		select_i,
	input	wire	[2 ** ADDRESS_WIDTH - 1:0]	clocks_i,
	output	wire								clock_o
);
localparam LENGTH = 2 ** ADDRESS_WIDTH;
wire [LENGTH - 1:0] selected;
wire [LENGTH - 1:0] strobed;
wire [LENGTH - 1:0] allow;
reg [LENGTH - 1:0] en_reg;
assign clock_o = |strobed;
tree_decoder #(.OUTPUT_WIDTH(LENGTH)) decode (
	.enable_i('1),
	.select_i(select_i),
	.data_o(selected)
);
genvar i;
genvar j;
generate
	for (i = 0; i < LENGTH; ++i) begin : clock_domain
		wire [LENGTH - 2:0] set_enable;
		for (j = 0; j < i; ++j) begin : junior
			assign set_enable[j] = en_reg[j];
		end
		for (j = i; j < LENGTH - 1; ++j) begin : senior
			assign set_enable[j] = en_reg[j + 1];
		end
		assign strobed[i] = clocks_i[i] & en_reg[i];
		always_ff @(posedge arst_i or negedge clocks_i[i]) begin
			if (arst_i) begin
				en_reg[i] <= '0;
			end else begin
				en_reg[i] <= selected[i] & ~|set_enable;
			end
		end
	end
endgenerate
endmodule