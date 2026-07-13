/*
Provides:
	Dual port memory (write and read)
Dependencies:
	None
Parameters:
	WORD_WIDTH		- width of word to store
	ADDRESS_WIDTH	- how many memory cell will be
	READERS_NUM		- how many readers
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	we_i			- write enable
	addr_read_i		- address to read
	addr_write_i	- address to write
	data_i			- data to store
	data_o			- data from RAM
Generation:
	data_o per reader
Additional comments:
	None
*/
module dual_port_memory #(
	parameter WORD_WIDTH,
	parameter ADDRESS_WIDTH,
	parameter READERS_NUM = 1
) (
	input	wire												clk_i,
	input	wire												arst_i,
	input	wire												we_i,
	input	wire	[READERS_NUM - 1:0][ADDRESS_WIDTH - 1:0]	addr_read_i,
	input	wire	[ADDRESS_WIDTH - 1:0]						addr_write_i,
	input	wire	[WORD_WIDTH - 1:0]							data_i,
	output	wire	[READERS_NUM - 1:0][WORD_WIDTH - 1:0]		data_o
);
reg [2 ** ADDRESS_WIDTH - 1:0][WORD_WIDTH - 1:0] mem;
genvar i;
generate
	for (i = 0; i < READERS_NUM; ++i) begin : reader
		assign data_o[i] = mem[addr_read_i[i]];
	end
endgenerate
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		mem <= '0;
	end else if (we_i) begin
		mem[addr_write_i] <= data_i;
	end
end
endmodule