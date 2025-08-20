module task_counter_forward #(
	parameter WORD_WIDTH
);
logic clock = '0;
logic [WORD_WIDTH - 1:0] data_i;
logic arst = '0;
logic action = '0;
wire [WORD_WIDTH - 1:0] data_o;
wire will_overflow;
always #10 clock = ~clock;
counter_forward #(.WORD_WIDTH(WORD_WIDTH)) cc (
	.clk_i(clock),
	.action_i(action),
	.arst_i(arst),

	.data_i(data_i),
	.data_o(data_o),

	.will_overflow_o(will_overflow)
);
task run;
	begin
		arst = '1;
		data_i = 0;
		#10
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		arst = '0;
		data_i = 1;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		data_i = 2;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		action = '1;
		data_i = 20;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
	end
endtask
endmodule