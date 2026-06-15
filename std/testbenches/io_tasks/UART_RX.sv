module task_UART_RX;
logic clk = '0;
logic RX_clk = '0;
logic arst = '0;
logic [19:0] LINE;
wire [7:0] data;
wire ready;

always #95 clk = ~clk; //100, 5% latency
always #10 RX_clk = ~RX_clk;
always_ff @(posedge clk) begin
	LINE <= {1'b1, LINE[19:1]};
end

UART_RX #(
	.WORD_WIDTH(8),
	.FREQ_PRECISION(10)
) RX (
	.clk_i(RX_clk),
	.arst_i(arst),
	.RX_i(LINE[0]),
	.data_from_RX_o(data),
	.data_ready_o(ready)
);

task run;
	begin
		LINE = {5'b11111, 10'b1011001100, 5'b11111 };
		arst = '1;
		#5
		$display("STATE: %b, WORD %b, LINE %b", ready, data, LINE);
		arst = '0;
		#1000000
		$display("STATE: %b, WORD %b, LINE %b", ready, data, LINE);
		LINE = {5'b11111, 10'b1000110000, 5'b11111 };
		#1000000
		$display("STATE: %b, WORD %b, LINE %b", ready, data, LINE);
	end
endtask
endmodule