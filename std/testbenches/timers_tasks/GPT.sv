module task_MONO_GPT;
logic reset;
logic clk = '0;
logic action_enable = '0;
logic [1:0] action = '0;
logic [15:0] value = '0;
wire target_irq;
wire overflow_irq;
always #5 clk = ~clk;
MONO_GPT #(.PS_WORD_WIDTH(4), .CNTR_WORD_WIDTH(16)) mono_gpt (
	.clk_i(clk),
	.arst_i(reset),

	.value_i(value),

	.ae_i(action_enable), //action enable
	.action_i(action),

	.target_irq_o(target_irq),
	.overflow_irq_o(overflow_irq)
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
		//set cmp
		@(negedge clk);
		action_enable = '1;
		action = 1;
		value = 100;
		@(negedge clk);
		action_enable = '0;
		#50;

		


		#1000;
		$finish(0);
	end
endtask
initial begin
	/*
	$dumpfile("out.vcd");
	$dumpvars(0, mono_gpt);
	*/
end
endmodule
module task_POLY_GPT;
logic reset;
logic clk = '0;
logic action_enable = '0;
logic [1:0] action = '0;
logic [7:0] value = '0;
logic [7:0] cmp = '0;

always #5 clk = ~clk;
POLY_GPT #(
	.PS_WORD_WIDTH(4),
	.CNTR_WORD_WIDTH(8),
	.DESC_WORD_WIDTH(8),
	.CMP_NUM(2)
) poly_gpt (
	.clk_i(clk),
	.arst_i(reset),
	.value_i({cmp, value}),
	.ae_i(action_enable), //action enable
	.action_i(action)
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
		//set cmp
		@(negedge clk);
		action_enable = '1;
		action = 1;
		value = 100;
		cmp = 10;
		//set cmp
		@(negedge clk);
		value = 70;
		cmp = 16;
		@(negedge clk);
		action_enable = '0;

		#1000;

		//handle cmp
		@(negedge clk);
		action_enable = '1;
		action = 2;
		@(negedge clk);
		action_enable = '0;


		#2500;
		$finish(0);
	end
endtask
initial begin

	$dumpfile("out.vcd");
	$dumpvars(0, poly_gpt);

end
endmodule