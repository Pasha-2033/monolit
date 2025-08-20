module task_counter #(
	parameter WORD_WIDTH
);
logic clock = '0;
logic [WORD_WIDTH - 1:0] data_i;
logic count = '0;
logic load = '0;
logic arst = '0;
wire [WORD_WIDTH - 1:0] data_o;
wire will_overflow;
always #10 clock = ~clock;
counter #(.WORD_WIDTH(WORD_WIDTH)) cc (
	.clk_i(clock),
	.count_i(count),
	.load_i(load),
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
		load = '1;
		data_i = 6;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		load = '0;
		count ='1;
		data_i = 7;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		data_i = 8;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
		load = '1;
		data_i = 7;
		#20
		$display("%s\tEXPECTED: %d\tGOT: %d\t OVERFLOW %b", data_o == data_i ? "OK  " : "FAIL", data_i, data_o, will_overflow);
	end
endtask
endmodule