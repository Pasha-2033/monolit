module task_sync_queue_tri;
logic clk = '0;
logic reset;
logic push;
logic pop;
logic [7:0] data_to;
wire [7:0] data_from;
always #10 clk = ~clk;
sync_queue_tri #(.WORD_WIDTH(8), .LENGTH(4)) s_queue (
	.clk_i(clk),
	.arst_i(reset),
	.push_i(push),
	.pop_i(pop),

	.data_i(data_to),

	.data_o(data_from)
);
task run();
	begin
		reset = '1;
		push = '0;
		pop = '0;
		#5
		$display("data_o(%d)", data_from); //0
		reset = '0;
		push = '1;
		data_to = 1;
		#20
		$display("data_o(%d)", data_from); //1
		data_to = 2;
		#20
		$display("data_o(%d)", data_from); //1
		data_to = 3;
		#20
		$display("data_o(%d)", data_from); //1
		push = '0;
		pop = '1;
		#20
		$display("data_o(%d)", data_from); //2
		#20
		$display("data_o(%d)", data_from); //3
		#20
		$display("-----data_o(%d)-----", data_from); //???

		push = '1;
		pop = '0;
		data_to = 4;
		#20
		$display("data_o(%d)", data_from); //4 (-, -, -, 4)
		data_to = 5;
		#20
		$display("data_o(%d)", data_from); //4 (-, -, 5, 4)
		pop = '1;
		data_to = 6;
		#20
		$display("data_o(%d)", data_from); //5 (-, -, 6, 5)
		data_to = 7;
		#20
		$display("data_o(%d)", data_from); //6 (-, -, 7, 6)
		push = '0;
		#20
		$display("data_o(%d)", data_from); //7 (-, -, -, 7)
		#20
		$display("data_o(%d)", data_from); //z (-, -, -, -)
	end
endtask
endmodule
module task_sync_queue_bin;
logic clk = '0;
logic reset;
logic push;
logic pop;
logic [7:0] data_to;
wire [7:0] data_from;
wire [1:0] point;
always #10 clk = ~clk;
sync_queue_bin #(.WORD_WIDTH(8), .ADDRESS_WIDTH(2)) s_queue (
	.clk_i(clk),
	.arst_i(reset),
	.push_i(push),
	.pop_i(pop),

	.data_i(data_to),

	.data_o(data_from),

	.point(point)
	//.is_empty,
	//.is_full
);
task run();
	begin
		reset = '1;
		push = '0;
		pop = '0;
		#5
		$display("data_from(%d), point(%d)", data_from, point); //0 (-, -, -, -)
		reset = '0;
		push = '1;
		data_to = 1;
		#20
		$display("data_from(%d), point(%d)", data_from, point); //1 (-, -, -, 1)
		data_to = 2;
		#20
		$display("data_from(%d), point(%d)", data_from, point); //1 (-, -, 2, 1)
		data_to = 3;
		#20
		$display("data_from(%d), point(%d)", data_from, point); //1 (-, 3, 2, 1)
		data_to = 4;
		#20
		$display("data_from(%d), point(%d)", data_from, point); //1 (4, 3, 2, 1)
		push = '0;
		pop = '1;
		#20
		$display("data_from(%d), point(%d)", data_from, point); //2 (-, 4, 3, 2)
		#20
		$display("data_from(%d), point(%d)", data_from, point); //3 (-, -, 4, 3)
		#20
		$display("data_from(%d), point(%d)", data_from, point); //4 (-, -, -, 4)
		#20
		$display("data_from(%d), point(%d)", data_from, point); //must be overflow :)
	end
endtask
endmodule