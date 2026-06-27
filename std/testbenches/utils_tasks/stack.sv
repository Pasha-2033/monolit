module task_sync_stack_bin;
logic clk = '0;
logic reset;
logic push;
logic pop;
logic [7:0] data_to;
wire [7:0] data_from;
wire [1:0] point;
always #10 clk = ~clk;
sync_stack_bin #(.WORD_WIDTH(8), .ADDRESS_WIDTH(2)) s_stack (
	.clk_i(clk),
	.arst_i(reset),
	.push_i(push),
	.pop_i(pop),
	.data_i(data_to),
	.data_o(data_from),
	.point(point)
);
task run();
	begin
		reset = '1;
		push = '0;
		pop = '0;
		#5
		$display("data_from(%d), point(%d)", data_from, point);
		reset = '0;
		push = '1;
		data_to = 1;
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		data_to = 2;
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		data_to = 3;
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		data_to = 4;
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		push = '0;
		pop = '1;
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		#20
		$display("data_from(%d), point(%d)", data_from, point);
		#20
		$display("data_from(%d), point(%d)", data_from, point); //must be overflow :)
	end
endtask
endmodule
module task_sync_stack_tri;
logic clk = '0;
logic reset;
logic push;
logic pop;
logic [7:0] data_to;
wire [7:0] data_from;
wire empty;
wire full;
always #10 clk = ~clk;
sync_stack_tri #(.WORD_WIDTH(8), .LENGTH(8)) s_stack (
	.clk_i(clk),
	.arst_i(reset),
	.push_i(push),
	.pop_i(pop),
	.data_i(data_to),
	.data_o(data_from),
	.is_empty(empty),
	.is_full(full)
);
task run();
	begin
		reset = '1;
		push = '0;
		pop = '0;
		#5
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		reset = '0;
		push = '1;
		data_to = 1;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		data_to = 2;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		data_to = 3;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		data_to = 4;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		data_to = 5;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		push = '0;
		pop = '1;
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
		#20
		$display("data_from(%d), empty(%b), full(%b)", data_from, empty, full);
	end
endtask
endmodule