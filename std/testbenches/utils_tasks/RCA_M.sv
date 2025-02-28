module task_RCA_M #(
	parameter WORD_WIDTH
);
logic [WORD_WIDTH - 1:0] A;
logic [WORD_WIDTH - 1:0] B;
wire [WORD_WIDTH - 1:0] R;
wire C_OUT;
RCA_M #(.WORD_WIDTH(WORD_WIDTH)) rca_m (
	.c_i('0),
	.a_i(A),
	.b_i(B),
	.r_o(R),
	.c_o(C_OUT)
);
task run(input [WORD_WIDTH - 1:0] A_VAL, input [WORD_WIDTH - 1:0] B_VAL);
	begin
		A = A_VAL;
		B = B_VAL;
		#10
		$display("%s\tEXPECTED: %b(%d)\tGOT: %b(%d)\tA: %b(%d)\tB: %b(%d)", R == (A + B) ? "OK  " : "FAIL", A + B, A + B, R, R, A, A, B, B);
	end
endtask
endmodule