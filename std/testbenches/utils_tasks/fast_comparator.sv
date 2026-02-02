module task_fast_comparator #(
	parameter WORD_WIDTH
);
integer errors;
logic [WORD_WIDTH - 1:0] A;
logic [WORD_WIDTH - 1:0] B;
wire above, below;
wire cpm_a, cmp_b;
assign cmp_a = (A > B);
assign cmp_b = (A < B);
fast_comparator #(.WORD_WIDTH(WORD_WIDTH)) fc (
	.a_i(A),
	.b_i(B),
	.above_o(above),
	.below_o(below)
);
task run(input [WORD_WIDTH - 1:0] A_VAL, input [WORD_WIDTH - 1:0] B_VAL);
	begin		
		A = A_VAL;
		B = B_VAL;
		#200
		//$display("%s\tEXPECTED: >%b <%b\tGOT: >%b <%b\tA: %d(%b)\tB: %d(%b)", ((cmp_a == above) && (cmp_b == below)) ? "OK" : "FAIL", cmp_a, cmp_b, above, below, A, A, B, B);
		if (!((cmp_a == above) && (cmp_b == below))) begin
			$display("FAIL:\tEXPECTED: >%b <%b\tGOT: >%b <%b\tA: %d(%b)\tB: %d(%b)", cmp_a, cmp_b, above, below, A, A, B, B);
		end
		//$display("%s\tEXPECTED: >%b <%b\tGOT: >%b <%b\tA: %d(%b)\tB: %d(%b)", ((cmp_a == above) && (cmp_b == below)) ? "OK" : "FAIL", cmp_a, cmp_b, above, below, A, A, B, B);
	end
endtask
endmodule