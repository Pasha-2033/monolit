module task_SPI #(
	parameter word_width,
	parameter SS_width,
	parameter send_width
);
bit clk;
bit SE;
bit WE;
bit	SSE;
logic [word_width - 1:0] D_IN;
logic [word_width - 1:0] OTHER_D;
wire [word_width - 1:0] D_OUT;
bit SS_IN;
wire SCLK = clk; //simplification - always use clk
wire [send_width - 1:0] SD_OUT;
wire [SS_width - 1:0] SS_OUT;
SPI #(.word_width(word_width), .send_width(send_width), .SS_width(SS_width)) spi (
	.clk(clk),
	.SE(SE),			//sync edge 0 - high, 1 - low (CPOL ^ CPHA)
	.WE(WE),			
	.SSE(SSE),		//slave seletion enable (can be set to 1 ONLY BY MASTER!!!)
	.SSV('1),		//slave selection value (decoder rerated tb)
	.D_IN(D_IN),
	.D_OUT(D_OUT),
	.SS_IN(SS_IN),		//slave selection (if master - always 1)
	.SCLK(clk),		//master and slave will use same SCLK for shift registers (but only master can clock - clk & en)
	.SD_IN(OTHER_D[word_width - 1:word_width - send_width]),		//MOSI - if slave else - MISO
	.SD_OUT(SD_OUT),		//MISO - if slave else - MOSI
	.SS_OUT(SS_OUT)		//slave selection
);
always #10 clk = ~clk;	//from master
always_ff @(posedge SCLK) begin
	OTHER_D <= {OTHER_D[word_width - send_width - 1:0], D_OUT[word_width - 1:word_width - send_width]};
end
task run_as_master(input [word_width - 1:0] MSD, input [word_width - 1:0] SSD, input sync_edge);
	begin
		SE = sync_edge;
		WE = '1;
		SSE = '0;
		D_IN = MSD;
		SS_IN = '0; //NOT: //always 1 for master
		#20;
		WE = '0;
		SSE = '1;
		OTHER_D = SSD;
		repeat (9) begin
			$display("%b\t%b", D_OUT, OTHER_D);
			#20;
		end
	end
endtask
task run_as_slave(input [word_width - 1:0] MSD, input [word_width - 1:0] SSD, input sync_edge);
	begin
		SE = sync_edge;
		WE = '1;
		SSE = '0;
		D_IN = SSD;
		SS_IN = '0; //prepare slave
		#20;
		WE = '0;
		SS_IN = '1; //use slave
		OTHER_D = MSD;
		repeat (9) begin
			$display("%b\t%b", D_OUT, OTHER_D);
			#20;
		end
	end
endtask
endmodule