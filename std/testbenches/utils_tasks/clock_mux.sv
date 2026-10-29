module task_clock_mux;
localparam CLK_ADDR_WIDTH = 2;
logic [CLK_ADDR_WIDTH - 1:0] clk_sel = 0;
logic [2 ** CLK_ADDR_WIDTH - 1:0] clk_i = '0;
logic reset;
wire clk_o;

always #5	clk_i[0] = ~clk_i[0];
always #7	clk_i[1] = ~clk_i[1];
always #11	clk_i[2] = ~clk_i[2];
always #13	clk_i[3] = ~clk_i[3];


clock_mux #(.ADDRESS_WIDTH(CLK_ADDR_WIDTH)) mux (
	.arst_i(reset),
	.select_i(clk_sel),
	.clocks_i(clk_i),
	.clock_o(clk_o)
);
task run;
	begin
		reset = '1;
		#100;
		reset = '0;
		#75
		clk_sel = 1;
		#75
		clk_sel = 2;
		#75
		clk_sel = 3;
	end
endtask
initial begin
	/*
	$dumpfile("out.vcd");
	$dumpvars(0, mux);
	*/
end
endmodule