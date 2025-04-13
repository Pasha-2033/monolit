module SPI #(
	parameter word_width = 8,
	parameter send_width = 1,
	parameter SS_width = 1
) (
	input	wire										clk,
	input	wire										SE,			//sync edge 0 - high, 1 - low (CPOL ^ CPHA)
	input	wire										WE,			
	input	wire										SSE,		//slave seletion enable (can be set to 1 ONLY BY MASTER!!!)
	input	wire	[$clog2(`max(SS_width, 2)) - 1:0]	SSV,		//slave selection value
	input	wire	[word_width - 1:0]					D_IN,
	output	reg		[word_width - 1:0]					D_OUT,
	//SPI interface
	input	wire										SS_IN,		//slave selection (if master - always 1)
	input	wire										SCLK,		//master and slave will use same SCLK for shift registers (but only master can clock - clk & en)
	input	wire	[send_width - 1:0]					SD_IN,		//MOSI - if slave else - MISO
	output	wire	[send_width - 1:0]					SD_OUT,		//MISO - if slave else - MOSI
	output	wire	[SS_width - 1:0]					SS_OUT		//slave selection
);
tree_decoder #(.OUTPUT_WIDTH(SS_width)) SS_decoder (
	.enable_i(SSE),
	.select_i(SSV),
	.out(SS_OUT)
);
assign SD_OUT = D_OUT[word_width - 1:word_width - send_width];
wire SPI_clk = SE ^ SCLK;
/*
always_ff @(posedge SPI_clk) begin
	if (~SSE) begin
		if (WE) begin
			D_OUT <= D_IN;
		end
	end else begin
		//D_OUT <= {D_OUT[send_width - 1:0], SD_IN};
		D_OUT <= {D_OUT[word_width - send_width - 1:0], SD_IN};
	end
end
*/
always_ff @(posedge SPI_clk) begin
	if (SSE | SS_IN) begin
		if (send_width < word_width) begin
			D_OUT <= {D_OUT[word_width - send_width - 1:0], SD_IN};
		end else begin
			D_OUT <= SD_IN;
		end
	end else if (WE) begin
		D_OUT <= D_IN;
	end
end
endmodule