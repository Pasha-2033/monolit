module task_SPI_X_slave;
logic R;
logic clk = '0;
logic X_clk = '0;
logic master_clk = '0;
logic reset;
logic push_word;
logic pop_word;
logic SS;
logic [7:0] data_to;
logic [7:0] master_value = '0;
wire [7:0] data_from;
wire LINE_to_master;
always #5 clk = ~clk;
always #2 X_clk = ~X_clk;
SPI_X_slave #(
	.WORD_WIDTH(8), 
	.BUFFER_ADDRESS_WIDTH(3),
	.RX_ALMOST_FULL_THRESHOLD(2),
	.RX_ALMOST_EMPTY_THRESHOLD(2),
	.TX_ALMOST_FULL_THRESHOLD(2)
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
    .MOSI_i(master_value[7]),
    .MISO_o(LINE_to_master),

	.CPOL(0),
	.CPHA(0)
);
task run;
	begin
		reset = '1;
		push_word = '0;
		pop_word = '0;
		master_clk = '0;
		SS = '1;
		#1
		$display("SLAVE: %b", data_from);
		reset = '0;
		repeat (100) begin
			@(posedge clk);
		end
		//---------
		@(negedge clk);
		push_word = '1;
		data_to = '1;
		//---------
		@(negedge clk);
		data_to = 8'b10011001;
		@(negedge clk);
		push_word = '0;
		//---------
		#100
		fork
			begin
				#100;
				//repeat (5) begin
				//	repeat ($size(master_value) * 2 + 2) begin
				//		#27; master_clk = ~master_clk;
				//	end
				//end
			end
			begin
				R = '0;
				SS = '0;
				master_value = 8'b01100110;
				#27
				repeat ($size(master_value)) begin
					$display("SLAVE: %b, MASTER: %b", data_from, master_value);
					#27; master_clk = '1;
					#27; master_clk = '0;
					master_value = {master_value[6:0], LINE_to_master};
				end
				$display("SLAVE: %b, MASTER: %b", data_from, master_value);
				$display("------------");
				master_value = 8'b00100100;
				repeat ($size(master_value)) begin
					$display("SLAVE: %b, MASTER: %b", data_from, master_value);
					#27; master_clk = '1;
					#27; master_clk = '0;
					master_value = {master_value[6:0], LINE_to_master};
				end
				$display("SLAVE: %b, MASTER: %b", data_from, master_value);
				$display("------------");
				master_value = 8'b11100111;
				repeat ($size(master_value)) begin
					$display("SLAVE: %b, MASTER: %b", data_from, master_value);
					#27; master_clk = '1;
					#27; master_clk = '0;
					master_value = {master_value[6:0], LINE_to_master};
				end
				$display("SLAVE: %b, MASTER: %b", data_from, master_value);
				$display("------------");
				master_value = 8'b11001100;
				repeat ($size(master_value)) begin
					$display("SLAVE: %b, MASTER: %b", data_from, master_value);
					#27; master_clk = '1;
					#27; master_clk = '0;
					master_value = {master_value[6:0], LINE_to_master};
				end
				$display("SLAVE: %b, MASTER: %b", data_from, master_value);
				#27
				SS = '1;
			end
		join
		#1000
		@(negedge clk);
		pop_word = '1;
		@(posedge clk);
		$display("!SLAVE: %b, MASTER: %b", data_from, master_value);
		@(posedge clk);
		$display("!SLAVE: %b, MASTER: %b", data_from, master_value);
		@(posedge clk);
		$display("!SLAVE: %b, MASTER: %b", data_from, master_value);
		@(posedge clk);
		$display("!SLAVE: %b, MASTER: %b", data_from, master_value);
	end
endtask
/*
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0, spi_slave);
end
*/
endmodule