/*
Provides:
	Clock Domain Crossing Handshake
Dependencies:
	r2s_sync
Parameters:
	WORD_WIDTH	- width of word to transmit
Ports:
	arst_i		- asynchronous reset
	clk_src_i	- source clock
	data_src_i	- data from source
	valid_src_i	- data_src_i is ready for reading
	ready_src_o	- module is ready for new handshake
	clk_dst_i	- destination clock
	data_dst_o	- data to destination
	valid_dst_o	- data_dst_o is ready for writing
Generation:
	None
Additional comments:
	valid signals should be strobe, not level
*/
module cdc_handshake #(
	parameter WORD_WIDTH
) (
	input	wire						arst_i,

	input	wire						clk_src_i,
	input	wire	[WORD_WIDTH - 1:0]	data_src_i,
	input	wire						valid_src_i,
	output	wire						ready_src_o,

	input	wire						clk_dst_i,
	output	reg		[WORD_WIDTH - 1:0]	data_dst_o,
	output	wire						valid_dst_o
);
reg req;
reg ack;
reg [WORD_WIDTH - 1:0] data_src_reg;
wire req_synced;
wire ack_synced;
assign ready_src_o = ~(req | ack_synced);
assign valid_dst_o = ack;
//assign valid_dst_o = req_synced & ~ack;
r2s_sync sync_req (
	.clk_dst_i(clk_dst_i),
	.arst_i(arst_i),
	.sig_i(req),
	.sig_o(req_synced)
);
r2s_sync sync_ack (
	.clk_dst_i(clk_src_i),
	.arst_i(arst_i),
	.sig_i(ack),
	.sig_o(ack_synced)
);
always @(posedge clk_src_i or posedge arst_i) begin
	if (arst_i) begin
		req <= '0;
		data_src_reg <= '0;
	end else begin
		if (valid_src_i & ready_src_o) begin
			data_src_reg <= data_src_i;
			req <= '1;
		end else if (req & ack_synced) begin
			req <= '0;
		end
	end
end
always @(posedge clk_dst_i or posedge arst_i) begin
	if (arst_i) begin
		ack <= '0;
		data_dst_o <= '0;
	end else begin
		if (req_synced & ~ack) begin
			data_dst_o <= data_src_reg;
			ack <= '1;
		end else if (~req_synced & ack) begin
			ack <= '0;
		end
	end
end
endmodule