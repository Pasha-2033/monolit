module task_UART_TX;
logic RX_clk = '0;
logic TX_clk = '0;
logic arst = '0;
logic set_TX = '0;

wire LINE;

logic [7:0] TX_data;
wire [7:0] RX_data;
wire RX_ready;
wire TX_ready;

always #48 TX_clk = ~TX_clk; //4% latency
always #10 RX_clk = ~RX_clk;

UART_RX #(
	.WORD_WIDTH(8),
	.FREQ_PRECISION(5)
) RX (
	.clk_i(RX_clk),
	.arst_i(arst),
	.RX_i(LINE),
	.data_from_RX_o(RX_data),
	.data_ready_o(RX_ready)
);
UART_TX #(
	.WORD_WIDTH(8)
) TX (
	.clk_i(TX_clk),
	.arst_i(arst),
	.TX_o(LINE),
	.set_word_i(set_TX),
	.data_to_TX_i(TX_data),
	.TX_ready_o(TX_ready)
);

task run;
	begin
		arst = '1;
		#5
		$display("STATE: %b, WORD %b", RX_ready, RX_data);
		$display("STATE: %b, LINE %b", TX_ready, LINE);
		$display("------------------------");
		arst = '0;
		#5
		set_TX = '1;
		TX_data = 8'b00111100;
		#200 //make sure TX got task
		$display("STATE: %b, WORD %b", RX_ready, RX_data);
		$display("STATE: %b, LINE %b", TX_ready, LINE);
		$display("------------------------");
		set_TX = '0;
		#1000
		$display("STATE: %b, WORD %b", RX_ready, RX_data);
		$display("STATE: %b, LINE %b", TX_ready, LINE);
	end
endtask
endmodule