module task_SPI #(
	parameter word_width,
	parameter SS_width
);
integer word_counter;
bit is_master;
bit outer_clk;
bit inner_clk;
bit SE;
bit WE;
bit	SSE;
logic [word_width - 1:0] D_IN;
logic [word_width - 1:0] OTHER_D;
wire [word_width - 1:0] D_OUT;
bit SS_IN;
wire SCLK = is_master ? inner_clk : outer_clk; //simplification - always use clk
wire SD_OUT;
wire [SS_width - 1:0] SS_OUT;
SPI #(.word_width(word_width), .SS_width(SS_width)) spi (
	.clk(inner_clk),
	.SE(SE),			//sync edge 0 - high, 1 - low (CPOL ^ CPHA)
	.WE(WE),			
	.SSE(SSE),		//slave seletion enable (can be set to 1 ONLY BY MASTER!!!)
	.SSV('1),		//slave selection value (decoder rerated tb)
	.D_IN(D_IN),
	.D_OUT(D_OUT),
	.SS_IN(SS_IN),		//slave selection (if master - always 1)
	.SCLK(SCLK),		//master and slave will use same SCLK for shift registers (but only master can clock - clk & en)
	.SD_IN(OTHER_D[word_width - 1]),		//MOSI - if slave else - MISO
	.SD_OUT(SD_OUT),		//MISO - if slave else - MOSI
	.SS_OUT(SS_OUT)		//slave selection
);
always #10 inner_clk = ~inner_clk;
always #15 outer_clk = ~outer_clk;
always_ff @(posedge SCLK & SSE) begin
	OTHER_D <= {OTHER_D[word_width - 2:0], D_OUT[word_width - 1]};
	word_counter = word_counter - 1;
end
task run_as_master(input [word_width - 1:0] MSD, input [word_width - 1:0] SSD, input sync_edge);
	begin
		is_master = '1;
		#50;
		SE = sync_edge;
		WE = '1;
		SSE = '0;
		D_IN = MSD;
		OTHER_D = SSD;
		SS_IN = '1; //always 1 for master
		#20;
		WE = '0;
		SSE = '1;
		word_counter = word_width + 1;
		while (word_counter) begin
			$display("%b\t%b", D_OUT, OTHER_D);
			#20;
		end
	end
endtask
task run_as_slave(input [word_width - 1:0] MSD, input [word_width - 1:0] SSD, input sync_edge);
	begin
		is_master = '0;
		#50;
		SE = sync_edge;
		WE = '1;
		SSE = '0;
		D_IN = SSD;
		SS_IN = '1; //prepare slave
		#20;
		WE = '0;
		SSE = '1;
		SS_IN = '0; //use slave
		#10;
		OTHER_D = MSD;
		word_counter = word_width + 1;
		while (word_counter) begin
			$display("%b\t%b", D_OUT, OTHER_D);
			#30;
		end
	end
endtask
endmodule