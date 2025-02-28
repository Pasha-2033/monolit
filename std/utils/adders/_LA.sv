/*
p_irovides:
	Lookahead for CLAA
Dependencies:
	NONE
Parameters:
	CASCADE_SIZE - nuber of adders to handle
Ports:
	c_i	- carry input
	p_i		- propagation
	g_i		- generation
	c_o		- carry for CLAA units
	pg_o	- propagation group
	gg_o	- generation group
Generation:
	Creates propagation and generation groups
Additional comments:
	Fully combinational
*/
module _LA #(
	parameter CASCADE_SIZE
) (
	input	wire						c_i,
	input	wire [CASCADE_SIZE - 1:0]	p_i,
	input	wire [CASCADE_SIZE - 1:0]	g_i,
	output	wire [CASCADE_SIZE:0]		c_o,

	output	wire						pg_o,
	output	wire						gg_o
);
wire [CASCADE_SIZE - 1:0] pre_gg;
assign c_o = {g_i | (p_i & c_o[CASCADE_SIZE - 1:0]), c_i};
assign pg_o = &p_i;
assign gg_o = |pre_gg;

//lookahead implementation
genvar i;
generate
	for(i = 0; i < CASCADE_SIZE; ++i) begin: signal_cascade
		if (i == CASCADE_SIZE - 1) begin
			assign pre_gg[i] = g_i[i];
		end 
		else begin
			assign pre_gg[i] = g_i[i] & (&p_i[CASCADE_SIZE - 1:i + 1]);
		end 
	end
endgenerate
endmodule