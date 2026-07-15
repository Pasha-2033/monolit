module task_UART_as_RX;
logic RX_clk = '0;
logic L_clk = '1;
logic mc_clk = '1;
logic arst;
logic [8:0] LINE;
wire [7:0] data_from;
logic [7:0] data_to;
logic push_word;
logic pop_word;

always #5 mc_clk = ~mc_clk;
always #10 RX_clk = ~RX_clk;
always #40 L_clk = ~L_clk;

UART #(.WORD_WIDTH(8), .BUFFER_ADDRESS_WIDTH(3)) uart (
	.clk_i(mc_clk),
	.clk_to_RX_i(RX_clk),
	.clk_to_TX_i(L_clk),
	.arst_i(arst),

	.push_word_i(push_word),
	.pop_word_i(pop_word),

	.data_i(data_to),
	.data_o(data_from),

	.RX_i(LINE[0])
);

task run_RX;
	begin
		arst = '1;
		pop_word = '0;
		push_word = '0;
		LINE = '1;
		#1
		$display("FROM: %b", data_from);
		arst = '0;
		repeat (3) begin
			@(posedge L_clk);
		end
		LINE = {8'b01100110, 1'b0};
		repeat ($size(LINE) + 1) begin
			@(posedge L_clk);
			LINE = {1'b1, LINE[8:1]};
		end
		$display("FROM: %b", data_from);
		LINE = {8'b10011001, 1'b0 };
		repeat ($size(LINE) + 1) begin
			@(posedge L_clk);
			LINE = {1'b1, LINE[8:1]};
		end
		$display("FROM: %b", data_from);
		LINE = {8'b01010101, 1'b0 };
		repeat ($size(LINE) + 1) begin
			@(posedge L_clk);
			LINE = {1'b1, LINE[8:1]};
		end
		$display("FROM: %b", data_from);
		LINE = {8'b10101010, 1'b0};
		repeat ($size(LINE) + 1) begin
			@(posedge L_clk);
			LINE = {1'b1, LINE[8:1]};
		end
		$display("FROM: %b", data_from);
		#1000
		@(negedge mc_clk)
		pop_word = '1;
		@(posedge mc_clk);
		$display("FROM: %b!!!", data_from);
		@(posedge mc_clk);
		$display("FROM: %b", data_from);
		@(posedge mc_clk);
		$display("FROM: %b", data_from);
		@(posedge mc_clk);
		$display("FROM: %b", data_from);
		@(posedge mc_clk); //overflow
		$display("FROM: %b", data_from);
	end
endtask
endmodule
/*
module task_UART_as_TX;
logic uart_clk = '0;
logic arst;
wire LINE;
wire [7:0] data_from;
logic [7:0] data_to;
logic push_word;
logic pop_word;

always #10 uart_clk = ~uart_clk;


UART #(.WORD_WIDTH(8), .BUFFER_ADDRESS_WIDTH(3)) uart (
	.clk_i(uart_clk),
	.arst_i(arst),

	.push_word_i(push_word),
	.pop_word_i(pop_word),

	.data_i(data_to),
	.data_o(data_from),

	.RX_i(LINE),
	.TX_o(LINE)
);
task run_TX;
	begin
		arst = '1;
		#5
		$display("FROM: %b, LINE: %b", data_from, LINE);
		arst = '0;
		push_word = '1;
		pop_word = '0;
		data_to = 1;
		#20
		$display("FROM: %b, LINE: %b", data_from, LINE);
		push_word = '0;
		#20000
		$display("FROM: %b, LINE: %b!", data_from, LINE);
		push_word = '1;
		data_to = 2;
		#20
		$display("FROM: %b, LINE: %b", data_from, LINE);
		data_to = 3;
		#20
		$display("FROM: %b, LINE: %b", data_from, LINE);
		data_to = 4;
		#20
		$display("FROM: %b, LINE: %b", data_from, LINE);
		push_word = '0;
		#20000
		$display("FROM: %b, LINE: %b&", data_from, LINE);
		pop_word = '1;
		#20
		$display("-FROM: %b, LINE: %b", data_from, LINE);
		#20
		$display("-FROM: %b, LINE: %b", data_from, LINE);
		#20
		$display("-FROM: %b, LINE: %b", data_from, LINE);
	end
endtask
endmodule
*/