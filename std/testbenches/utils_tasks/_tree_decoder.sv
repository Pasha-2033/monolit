module task__tree_decoder #(
	parameter output_width
);
integer errors;
logic [$clog2(`max(output_width, 2)) - 1:0] S;
logic [output_width - 1:0] SE;
wire [output_width - 1:0] out;
_tree_decoder #(.output_width(output_width)) _td (
	.enable('1),
	.select(S),
	.out(out)
);
task run(input [$clog2(`max(output_width, 2)) - 1:0] S_VAL);
	begin		
		S = S_VAL;
		SE = 1 << S_VAL;
		#10
		$display("%s\tEXPECTED: %b(%d)\tGOT: %b(%d)\tS: %d", out == SE ? "OK  " : "FAIL", SE, SE, out, out, S);
	end
endtask
endmodule