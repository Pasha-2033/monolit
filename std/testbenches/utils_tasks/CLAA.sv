module task_CLAA #(
	parameter cascade_size,
	parameter word_width
);
integer errors;
logic [word_width - 1:0] A;
logic [word_width - 1:0] B;
wire [word_width - 1:0] R;
wire C_OUT;
CLAA #(.cascade_size(cascade_size), .word_width(word_width)) fa (
	.C_IN('0),
	.A(A),
	.B(B),
	.R(R),
	//ingore technical outupts P & G
	.C_OUT(C_OUT)
);
task run(input [word_width - 1:0] A_VAL, input [word_width - 1:0] B_VAL);
	begin		
		A = A_VAL;
		B = B_VAL;
		#10
		$display("%s\tEXPECTED: %b(%d)\tGOT: %b(%d)\tA: %b(%d)\tB: %b(%d)", R == (A + B) ? "OK  " : "FAIL", A + B, A + B, R, R, A, A, B, B);
	end
endtask
endmodule