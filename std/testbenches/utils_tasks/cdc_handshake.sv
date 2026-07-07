module task_cdc_handshake;
logic arst_i;
logic clk_src_i = '0;
logic clk_dst_i = '0;
logic [7:0] data_src_i;
logic valid_src_i;
logic ready_src_o;
wire [7:0] data_dst_o;
wire valid_dst_o;

always #5 clk_src_i = ~clk_src_i;
always #3 clk_dst_i = ~clk_dst_i;

cdc_handshake #(.WORD_WIDTH(8)) dut (
	.arst_i(arst_i),
	.clk_src_i(clk_src_i),
	.data_src_i(data_src_i),
	.valid_src_i(valid_src_i),
	.ready_src_o(ready_src_o),
	.clk_dst_i(clk_dst_i),
	.data_dst_o(data_dst_o),
	.valid_dst_o(valid_dst_o)
);

// Входные данные для передачи (массив)
logic [3:0][7:0] tx_data  = { 8'hA5, 8'h5A, 8'hFF, 8'h00 };
logic [7:0] expected;
int i;
int errors = 0;

task run();
	arst_i = 1;
	#1
	$display("%b", data_dst_o);
	arst_i = 0;
	for (i = 0; i < $size(tx_data); ++i) begin
		valid_src_i = '1;
		data_src_i = tx_data[i];
		@(posedge valid_dst_o);
		$display("TIME: %d\t DATA:%b\t valid_dst_o: %b \t ready_src_o %b", $time, data_dst_o, valid_dst_o, ready_src_o);
		@(negedge valid_dst_o);
		$display("TIME: %d\t DATA:%b\t valid_dst_o: %b \t ready_src_o %b", $time, data_dst_o, valid_dst_o, ready_src_o);
		@(posedge ready_src_o);
		$display("TIME: %d\t DATA:%b\t valid_dst_o: %b \t ready_src_o %b", $time, data_dst_o, valid_dst_o, ready_src_o);
	end
endtask
endmodule