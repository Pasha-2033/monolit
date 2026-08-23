module task_SPI_X_slave;
localparam LW = 12;
localparam WW = 12;
localparam TRANS_NUM = 6;
localparam bit CPOL = 1;
localparam bit CPHA = 1;
localparam CLK_FRONT_DELAY = 270;
logic clk = '0;
logic X_clk = '0;
logic master_clk;
logic reset;
logic push_word;
logic pop_word;
logic SS;
logic [WW:0] data_to;
logic [WW / LW - 1:0][LW - 1:0] line_value_from_slave;
logic [LW - 1:0] line_value_to_slave;
logic [WW / LW - 1:0][LW - 1:0] master_values [];
logic [WW / LW - 1:0][LW - 1:0] slave_values[];
wire [WW - 1:0] data_from;
wire [LW - 1:0] LINE_to_master;

logic [WW / LW - 1:0][LW - 1:0] acc_to_slave;
always #50 clk = ~clk;
always #2 X_clk = ~X_clk;
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

    .push_word_i(push_word),
	.pop_word_i(pop_word),
	.data_i(data_to),
	.data_o(data_from),

	.SCLK_i(master_clk),
    .SS_i(SS),
    .MOSI_i(line_value_to_slave),
    .MISO_o(LINE_to_master),

	.CPOL_i(CPOL),
	.CPHA_i(CPHA)
);
task run;
	begin
		reset = '1;
		push_word = '0;
		pop_word = '0;
		master_clk = CPOL;
		SS = '1;
		#5
		reset = '0;
		repeat (100) begin
			@(posedge clk);
		end
		//---------
		@(negedge clk);
		push_word = '1;
		for (int i = 0; i < TRANS_NUM; ++i) begin
			data_to = slave_values[i];
			@(negedge clk);
		end
		push_word = '0;
		//---------
		#100;
		fork
			begin
				//SCLK
				repeat (TRANS_NUM * 2 * WW / LW) begin
					#CLK_FRONT_DELAY; master_clk = ~master_clk;
				end
			end
			begin
				//SS
				SS = '0;
				#(CLK_FRONT_DELAY * ((TRANS_NUM * 2) * WW / LW + 1));
				SS = '1;
			end
			begin
				//MOSI
				if (CPHA) begin
					#CLK_FRONT_DELAY;
				end
				//we are not allowed to write master_values[i][WW / LW - ii - 1]! FUCK!!!
				for (int i = 0; i < TRANS_NUM; ++i) begin
					acc_to_slave = master_values[i];
					for (int ii = 0; ii < WW / LW; ++ii) begin
						line_value_to_slave = acc_to_slave[WW / LW - ii - 1];
						#(CLK_FRONT_DELAY * 2);
					end
				end
				line_value_to_slave = 'x;
			end
			begin
				//MISO
				if (CPHA) begin
					#(CLK_FRONT_DELAY * 2);
				end else begin
					#CLK_FRONT_DELAY;
				end
				for (int i = 0; i < TRANS_NUM; ++i) begin
					line_value_from_slave = 'x;
					for (int ii = 0; ii < WW / LW; ++ii) begin
						line_value_from_slave[WW / LW - ii - 1] = LINE_to_master;
						#(CLK_FRONT_DELAY * 2);
					end
					$display("!MASTER: %b %s [EXPECTED:%b]", line_value_from_slave, line_value_from_slave == slave_values[i] ? "OK" : "FAIL", slave_values[i]);
				end
			end
		join
		#1000;
		@(negedge clk);
		pop_word = '1;
		for (int i = 0; i < TRANS_NUM; ++i) begin
			@(posedge clk);
			$display("!SLAVE: %b %s [EXPECTED:%b]", data_from, data_from == master_values[i] ? "OK" : "FAIL", master_values[i]);
		end
		@(posedge clk); //prevent overreading (will cause overflow!!!)
		$display("---------\n!SLAVE: %b %s", data_from, data_from == 0 ? "OK" : "FAIL");
		@(negedge clk);
		pop_word = '0;
	end
endtask
initial begin
	master_values = new[TRANS_NUM];
	slave_values = new[TRANS_NUM];
	for (int i = 0; i < TRANS_NUM; ++i) begin
		master_values[i] = $urandom();
		slave_values[i] = $urandom();
	end
	/*
	$dumpfile("out.vcd");
	$dumpvars(0, spi_slave);
	*/
end
endmodule