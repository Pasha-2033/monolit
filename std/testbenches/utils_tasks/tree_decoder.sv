module task_tree_decoder #(
	parameter OUTPUT_WIDTH
);
integer errors;
logic [$clog2(`max(OUTPUT_WIDTH, 2)) - 1:0] S;
logic [OUTPUT_WIDTH - 1:0] SE;
wire [OUTPUT_WIDTH - 1:0] out;
tree_decoder #(.OUTPUT_WIDTH(OUTPUT_WIDTH)) _td (
	.enable_i('1),
	.select_i(S),
	.out(out)
);
task run(input [$clog2(`max(OUTPUT_WIDTH, 2)) - 1:0] S_VAL);
	begin		
		S = S_VAL;
		SE = 1 << S_VAL;
		#10
		$display("%s\tEXPECTED: %b(%d)\tGOT: %b(%d)\tS: %d", out == SE ? "OK  " : "FAIL", SE, SE, out, out, S);
	end
endtask
endmodule