/*
Provides:
	Two register data synchronizer
Dependencies:
	None
Parameters:
	WORD_WIDTH	- width of word to transmit
Ports:
	clk_dst_i	- destination domain clock
	arst_i		- asynchronous reset
	sig_i		- push word to queue
	sig_o		- pop word from queue
Generation:
	NONE
Additional comments:
	DO NOT use WORD_WIDTH > 1 if 2+ bits can be changed by transmition!
	Currently 2-stages, for very fast lock should be 3-stages (10^-30 failures per second)
*/
module r2s_sync #(
	parameter WORD_WIDTH = 1 //can be 2+ if we use Gray code for example
) (
	input	wire						clk_dst_i,
	input	wire						arst_i,
	input	wire	[WORD_WIDTH - 1:0]	sig_i, 
	output	reg		[WORD_WIDTH - 1:0]	sig_o     
);
reg [WORD_WIDTH - 1:0] meta;
always_ff @(posedge clk_dst_i or posedge arst_i) begin
	if (arst_i) begin
		meta <= '0;
		sig_o <= '0;
	end else begin
		meta <= sig_i;
		sig_o <= meta;
	end
end
endmodule