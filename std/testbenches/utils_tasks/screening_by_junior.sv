module task_screening_by_junior #(
	parameter WORD_WIDTH
);
logic [WORD_WIDTH - 1:0] A;
wire [WORD_WIDTH - 1:0] R;
wire C_OUT;
screening_by_junior #(.WORD_WIDTH(WORD_WIDTH)) sbj (
	.c_i('0),
	.in(A),
	.out(R),
	.c_o(C_OUT)
);
task run(input [WORD_WIDTH - 1:0] A_VAL);
	begin
		A = A_VAL;
		#10
		$display("?? \tGOT: %b\tA: %b", R, A);
	end
endtask
endmodule