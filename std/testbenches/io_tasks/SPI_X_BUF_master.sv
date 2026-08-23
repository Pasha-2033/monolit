module task_SPI_X_BUF_master;
localparam WW = 8;
localparam LW = 2;
localparam TRANS_NUM = 4; //1(0) + 3(2)
localparam bit CPOL = 0;
localparam bit CPHA = 1;
logic clk = '0;
logic X_clk = '0;
logic L_clk = '0;
logic reset = '0;
logic push_task = '0;
logic push_word_slave = '0;
logic pop_word_slave = '0;
logic push_word_master = '0;
logic pop_word_master = '0;
logic [WW - 1:0] data_to;
logic start = '0;
logic [2:0] NUM = 0;
wire [WW - 1:0] data_from_master;
wire [WW - 1:0] data_from_slave;
wire [LW - 1:0] LINE_MISO;
wire [LW - 1:0] LINE_MOSI;
wire [3:0] SS;
wire L;

logic [WW / LW - 1:0][LW - 1:0] values [TRANS_NUM];

always #5 clk = ~clk;
always #1 X_clk = ~X_clk;
always #27 L_clk = ~L_clk;
SPI_X_BUF_master #(
	.WORD_WIDTH(WW), 
	.DATA_BUFFER_ADDRESS_WIDTH(3),
	.RX_ALMOST_FULL_THRESHOLD(2),
	.RX_ALMOST_EMPTY_THRESHOLD(2),
	.TX_ALMOST_FULL_THRESHOLD(2),
	.SLAVE_ADDRESS_WIDTH(2),
	.TASK_BUFFER_ADDRESS_WIDTH(3),
	.TASK_ALMOST_FULL_THRESHOLD(2),
	.LINE_WIDTH(LW)
) spi_master (
	.clk_i(clk),
	.X_clk_i(X_clk),
	.L_clk_i(L_clk),
	.arst_i(reset),

	.push_word_i(push_word_master),
	.pop_word_i(pop_word_master),
	.data_i(data_to),
	.data_o(data_from_master),

	.push_task_i(push_task),
	.re_i('1),
	.we_i('1),
	.word_num_i(NUM),
	.slave_address_i('0),

	.SS_o(SS),
	.SCLK_o(L),
	.MOSI_o(LINE_MOSI),
	.MISO_i(LINE_MISO),

	.CPOL_i(CPOL),
	.CPHA_i(CPHA)
);
SPI_X_slave #(
	.WORD_WIDTH(WW), 
	.BUFFER_ADDRESS_WIDTH(3),
	.RX_ALMOST_FULL_THRESHOLD(2),
	.RX_ALMOST_EMPTY_THRESHOLD(2),
	.TX_ALMOST_FULL_THRESHOLD(2),
	.LINE_WIDTH(LW)
) spi_slave (
	.clk_i(clk),
	.X_clk_i(X_clk),
    .arst_i(reset),

    .push_word_i(push_word_slave),
	.pop_word_i(pop_word_slave),
	.data_i(~data_to),
	.data_o(data_from_slave),

	.SCLK_i(L),
    .SS_i(SS[0]),
    .MOSI_i(LINE_MOSI),
    .MISO_o(LINE_MISO),

	.CPOL_i(CPOL),
	.CPHA_i(CPHA)
);
task run;
	begin
		reset = '1;
		#1
		reset = '0;
		repeat (10) begin
			@(posedge clk);
		end
		@(negedge clk);
		push_word_master = '1;
		push_word_slave = '1;
		for (int i = 0; i < TRANS_NUM; ++i) begin
			data_to = values[i];
			@(negedge clk);
		end
		push_word_master = '0;
		push_word_slave = '0;

		#500;
		NUM = 0;
		@(negedge clk);
		push_task = '1;
		@(negedge clk);
		push_task = '0;

		#500;
		NUM = 2;
		@(negedge clk);
		push_task = '1;
		@(negedge clk);
		push_task = '0;

		#5000;
		@(negedge clk);
		pop_word_slave = '1;
		pop_word_master = '1;
		for (int i = 0; i < TRANS_NUM; ++i) begin
			$display("SLAVE: %b(%s), MASTER: %b(%s), REF: %b", data_from_slave, data_from_slave == values[i] ? "OK" : "FAIL", data_from_master, data_from_master == ~values[i] ?  "OK" : "FAIL", values[i]);
			@(negedge clk);
		end
		pop_word_slave = '0;
		pop_word_master = '0;
	end
endtask

initial begin
	for (int i = 0; i < TRANS_NUM; ++i) begin
		values[i] = $urandom();
	end
	/*
	$dumpfile("out.vcd");
	$dumpvars(0, spi_slave, spi_master);
	*/
end

endmodule