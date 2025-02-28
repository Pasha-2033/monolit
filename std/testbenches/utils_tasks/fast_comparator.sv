module task_fast_comparator #(
	parameter WORD_WIDTH
);
integer errors;
logic [WORD_WIDTH - 1:0] A;
logic [WORD_WIDTH - 1:0] B;
wire above, below;
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
		#20
		$display("%s\tEXPECTED: >%b <%b\tGOT: >%b <%b\tA: %d(%b)\tB: %d(%b)", (above ^ (A > B)) | (below ^ (A < B)) ? "FAIL" : "OK  ", A > B, A < B, above, below, A, A, B, B);
	end
endtask
endmodule