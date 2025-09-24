`include "utils.sv"
`include "RF/BPU.sv"
`timescale 1ps/1ps
module BPU_tb;
logic clock = '0;
logic arst;
logic conditional_jump;
logic shouldnt_jump;
wire [3:0] val;
wire j;
always #10 clock = ~clock;
BPU_LVL_1 #(.STEP_NUM(4), .JUMP_AREA(12)) bpu (
	.clk_i(clock),
	.arst_i(arst),

	.conditional_jump_i(conditional_jump),	//if jump happend
	.shouldnt_jump_i(shouldnt_jump),
	.bpu_counter_value(val),

	.jump_o(j)
);
initial begin
	arst = '1;
	#5
	$display("C: %b(%d), %b", val, val, j);
	arst = '0;
	conditional_jump = '1;
	shouldnt_jump = '0;
	#40
	$display("C: %b(%d), %b", val, val, j);
	conditional_jump = '1;
	shouldnt_jump = '1;
	#20
	$display("C: %b(%d), %b", val, val, j);
	#20
	$display("C: %b(%d), %b", val, val, j);
	#20
	$display("C: %b(%d), %b", val, val, j);
	#20
	$display("C: %b(%d), %b", val, val, j);
	conditional_jump = '1;
	shouldnt_jump = '0;
	repeat (20) begin
		#20
		$display("C: %b(%d), %b", val, val, j);
	end
end
endmodule