module task_fast_adder #(
	parameter cascade_size,
	parameter bit_width
);
logic [bit_width - 1:0] A;
logic [bit_width - 1:0] B;
wire [bit_width - 1:0] R;
wire C_OUT;
fast_adder #(.cascade_size(cascade_size), .bit_width(bit_width)) fa (
	.C_IN('0),
	.A(A),
	.B(B),
	.R(R),
	//ingore technical outupts P & G
	.C_OUT(C_OUT)
);
task run();
	//TODO: expand and make more infrormative
	begin		
		A = 10;
		B = 20;
		#10
		$display("%s\tEXPECTED: %b\tGOT: %b", R == (A + B) ? "OK  " : "FAIL", A + B, R);
		A = 0;
		B = -1;
		#10
		$display("%s\tEXPECTED: %b\tGOT: %b", R == (A + B) ? "OK  " : "FAIL", A + B, R);
		A = 1;
		B = -1;
		#10
		$display("%s\tEXPECTED: %b\tGOT: %b", R == (A + B) ? "OK  " : "FAIL", A + B, R);
	end
endtask
endmodule