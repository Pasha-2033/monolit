module task_counter_backward #(
	parameter WORD_WIDTH
);
logic clock = '0;
logic [WORD_WIDTH - 1:0] data_i;
logic arst = '0;
logic action = '0;
wire [WORD_WIDTH - 1:0] data_o;
wire will_underflow;
always #10 clock = ~clock;
counter_backward #(.WORD_WIDTH(WORD_WIDTH)) cb (
	.clk_i(clock),
	.action_i(action),
	.arst_i(arst),

	.data_i(data_i),
	.data_o(data_o),

	.will_underflow_o(will_underflow)
);
task run;
	begin
		arst = '1;
		data_i = 0;
		#10
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_underflow);
		arst = '0;
		data_i = -1;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_underflow);
		data_i = -2;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_underflow);
		action = '1;
		data_i = 20;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_underflow);
	end
endtask
endmodule