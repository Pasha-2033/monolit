module task_fast_comparator #(
	parameter word_width
);
integer errors;
logic [word_width - 1:0] A;
logic [word_width - 1:0] B;
wire above, below;
fast_comparator #(.word_width(word_width)) fc (
	.A(A),
	.B(B),
	.above(above),
	.below(below)
);
task run(input [word_width - 1:0] A_VAL, input [word_width - 1:0] B_VAL);
	begin		
		A = A_VAL;
		B = B_VAL;
		#20
		$display("%s\tEXPECTED: >%b <%b\tGOT: >%b <%b\tA: %d(%b)\tB: %d(%b)", (above ^ (A > B)) | (below ^ (A < B)) ? "FAIL" : "OK  ", A > B, A < B, above, below, A, A, B, B);
	end
endtask
endmodule