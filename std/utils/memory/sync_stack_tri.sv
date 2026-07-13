/*
Provides:
	Synchronous stack with 'z controlled output
Dependencies:
	NONE
Parameters:
	WORD_WIDTH	- width of word to store
	LENGTH		- number of memory cells
Ports:
	clk_i		- clock
	arst_i		- asynchronous reset
	push_i		- push word to stack
	pop_i		- pop word from stack
	data_i		- data for pushing
	data_o		- data from poping
	is_empty_o	- is stack empty?
	is_full_o	- is stack full?
Generation:
	assigning data_o with cells
Additional comments:
	DO NOT CAUSE OVERFLOW/UNDERFLOW!!!
	if empty - will send 'z, can be avoided by (is_empty_o & ~(push_i & pop_i)) ? '0 : 'z
*/
module sync_stack_tri #(
	parameter WORD_WIDTH,
	parameter LENGTH
) (
	input	wire						clk_i,
	input	wire						arst_i,
	input	wire						push_i,
	input	wire						pop_i,
	input	wire	[WORD_WIDTH - 1:0]	data_i,
	output	wire	[WORD_WIDTH - 1:0]	data_o,
	output	wire						is_empty_o,
	output	wire						is_full_o
);
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
reg [LENGTH:0] filled;
wire [WORD_WIDTH - 1:0] pre_data;
assign data_o = push_i & pop_i ? data_i : pre_data;
assign is_empty_o = filled[0];
assign is_full_o = filled[LENGTH];

genvar i;
generate
	for (i = 0; i < LENGTH; ++i) begin : output_collector
		assign pre_data = filled[i + 1] ? data[i] : 'z;
	end
endgenerate

integer ii;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
		filled[LENGTH:1] <= '0;
		filled[0] <= '1;
	end else begin
		if (push_i & ~pop_i) begin
			for (ii = 0; ii < LENGTH; ++ii) begin
				if (filled[ii]) begin
					data[ii] <= data_i;
				end
			end
			filled[LENGTH - 1:0] <= {filled[LENGTH - 2:0], 1'b0};
			filled[LENGTH] <= filled[LENGTH] ? '1 : filled[LENGTH - 1];
		end else if (~push_i & pop_i) begin
			filled[LENGTH:1] <= {1'b0, filled[LENGTH:2]};
			filled[0] <= filled[1] ? '1 : filled[0];
		end
	end
end
//OUTDATED (CODE ABOVE IS BETTER IF LENGTH IS BIGGER)
/*
reg [LENGTH - 1:0][WORD_WIDTH - 1:0] data;
reg [LENGTH - 1:0] filled;
wire [LENGTH - 1:0] output_allowed;
wire [LENGTH:0] push_dir;
wire [WORD_WIDTH - 1:0] pre_data;
assign output_allowed = {filled[LENGTH - 1], filled[LENGTH - 2:0] & ~filled[LENGTH - 1:1]};
assign push_dir = {filled, 1'b1};
assign data_o = push_i & pop_i ? data_i : pre_data;
assign is_empty_o = ~filled[0];
assign is_full_o = filled[LENGTH - 1];
genvar i;
generate
	for (i = 0; i < LENGTH; ++i) begin : output_collector
		assign pre_data = output_allowed[i] ? data[i] : 'z;
	end
endgenerate
integer ii;
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		data <= '0;
		filled <= '0;
	end else begin
		if (push_i & ~pop_i) begin		
			filled <= {filled[LENGTH - 2:0], 1'b1};
			for (ii = 0; ii < LENGTH; ++ii) begin
				if (push_dir[ii] & ~push_dir[ii + 1]) begin
					data[ii] <= data_i;
				end
			end
		end else if (~push_i & pop_i) begin
			filled <= {1'b0, filled[LENGTH - 1:1]};
		end
	end
end
*/
endmodule