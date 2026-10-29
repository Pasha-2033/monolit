module task_PIT;
logic reset;
logic clk = '0;
logic action_enable = '0;
logic [1:0] action = '0;
logic [3:0] value = '0;

wire irq;

always #5 clk = ~clk;


PIT #(.PS_WORD_WIDTH(4), .CNTR_WORD_WIDTH(4)) pit (
	.clk_i(clk),
	.arst_i(reset),
	.ae_i(action_enable),
	.action_i(action),
	.value_i(value),
	.irq_o(irq)
);


task run();
	begin
		reset = '1;
		#20;
		reset = '0;
		repeat (10) begin
			@(posedge clk);
		end
		//--------
		/*
		//set cntr
		@(negedge clk);
		action_enable = '1;
		action = 1;
		value = 4;
		@(negedge clk);
		action_enable = '0;
		*/
		#50;

		//set reset value
		@(negedge clk);
		action_enable = '1;
		action = 2;
		value = 4;
		//set mode
		@(negedge clk);
		action = 3;
		value = 1;
		@(negedge clk);
		action_enable = '0;

		#50;
		//check prescaler
		@(negedge clk);
		action_enable = '1;
		action = 0;
		value = 2;
		@(negedge clk);
		action_enable = '0;


		#1000;
		$finish(0);
	end
endtask
initial begin
	/*
	$dumpfile("out.vcd");
	$dumpvars(0, pit);
	*/
end
endmodule