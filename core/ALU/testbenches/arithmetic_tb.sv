`include "utils/adders/_LA.sv"
`include "utils/adders/CLAA.sv"
//`include "blocks/eub.sv"
`include "units/eau.sv"
`timescale 1ps/1ps
module arithmetic_tb;
enum logic[1:0] {XXXX_ADD, X_ADD, PREV_ADD, CF_ADD} [3:0] add_type;
logic CF_to_adder;
logic [3:0] is_sub_to_adder;
logic [3:0][7:0] A;
logic [3:0][7:0] B;
wire [3:0][7:0] R;
wire [4:0] CF_from_adder;
EAU eau (
	.CF_i(CF_to_adder),
	.is_sub_i(is_sub_to_adder),
	.sub_unit_control_i(add_type),	//adder CF selection

	.a_i(A),
	.b_i(B),
	.not_a_i(~A),
	.r_o(R),

	.CF_o(CF_from_adder)
);
integer i;
initial begin
	add_type = {XXXX_ADD, XXXX_ADD, XXXX_ADD, XXXX_ADD};
	//check 32x normal add
	CF_to_adder = '0;
	is_sub_to_adder = '0;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R != A + B) begin
			$display("1.EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A + B, R, A, B);
		end
	end
	//check 32x normal sub
	is_sub_to_adder = '1;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R != A - B) begin
			$display("2.EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A - B, R, A, B);
		end
	end
	//check 32x normal adc
	is_sub_to_adder = '0;
	CF_to_adder = '1;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R != A + B + 1) begin
			$display("3.EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A + B + 1, R, A, B);
		end
	end
	//check 32x normal sbb
	is_sub_to_adder = '1;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R != A - B - 1) begin
			$display("4.EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A - B - 1, R, A, B);
		end
	end

	//check 24x add & 8x add
	add_type = {PREV_ADD, PREV_ADD, X_ADD, X_ADD};
	is_sub_to_adder = '0;
	CF_to_adder = '0;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R[0] != A[0] + B[0]) begin
			$display("5[0].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[0] + B[0], R, A[0], B[0]);
		end
		if (R[3:1] != A[3:1] + B[3:1]) begin
			$display("5[3:1].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[3:1] + B[3:1], R, A[3:1], B[3:1]);
		end
	end
	//check 24x add & 8x sub
	is_sub_to_adder[0] = '1;
	CF_to_adder = '0;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R[0] != A[0] - B[0]) begin
			$display("6[0].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[0] - B[0], R, A[0], B[0]);
		end
		if (R[3:1] != A[3:1] + B[3:1]) begin
			$display("6[3:1].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[3:1] + B[3:1], R, A[3:1], B[3:1]);
		end
	end
	//check 24x sub & 8x add
	is_sub_to_adder[0] = '0;
	is_sub_to_adder[3:1] = '1;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R[0] != A[0] + B[0]) begin
			$display("7[0].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[0] + B[0], R, A[0], B[0]);
		end
		if (R[3:1] != A[3:1] - B[3:1]) begin
			$display("7[3:1].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[3:1] - B[3:1], R, A[3:1], B[3:1]);
		end
	end
	//check 16x add & 16x add
	add_type = {PREV_ADD, X_ADD, PREV_ADD, X_ADD};
	is_sub_to_adder = '0;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R[1:0] != A[1:0] + B[1:0]) begin
			$display("8[1:0].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[1:0] + B[1:0], R, A[0], B[0]);
		end
		if (R[3:2] != A[3:2] + B[3:2]) begin
			$display("8[3:3].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[3:2] + B[3:2], R, A[3:2], B[3:2]);
		end
	end
	//check 16x add & 16x sub
	is_sub_to_adder[1:0] = '1;
	repeat (200) begin
		A = $urandom;
		B = $urandom;
		#10
		if (R[1:0] != A[1:0] - B[1:0]) begin
			$display("9[1:0].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[1:0] - B[1:0], R, A[0], B[0]);
		end
		if (R[3:2] != A[3:2] + B[3:2]) begin
			$display("9[3:3].EXPECTED: %d\tGOT: %d\tA: %d\tB: %d", A[3:2] + B[3:2], R, A[3:2], B[3:2]);
		end
	end




	add_type = {X_ADD, X_ADD, X_ADD, X_ADD};
	is_sub_to_adder = '0;
	repeat (200) begin
		A= $urandom;
		B = $urandom;
		#10
		for (i = 0; i < 4; ++i) begin
			if (R[i] != A[i] + B[i]) begin
				$display("5.%d\tEXPECTED: %d\tGOT: %d\tA: %d\tB: %d", i, A[i] + B[i], R[i], A[i], B[i]);
			end
		end
	end
end
endmodule