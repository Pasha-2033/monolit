`include "utils.sv"
`include "_tree_decoder.sv"
`include "CLAA.sv"
`include "CSA_S.sv"
`include "fast_comparator.sv"
`include "polyshift_r.sv"
`include "polyshift_l.sv"
`include "RCA_M.sv"
`timescale 1ps/1ps
module utils_tb;
task__tree_decoder #(.output_width(12)) _td();
task_CLAA #(.word_width(16)) claa();
task_CSA_S #(.word_width(16), .unit_width(4)) csa_s();
task_fast_comparator #(.word_width(7)) fc();
task_polyshift_r #(.word_width(8)) psr();
task_polyshift_l #(.word_width(8)) psl();
task_RCA_M #(.word_width(16)) rca_m();
initial begin
	$display("_tree_decoder task:");
	_td.run(0);
	_td.run(1);
	_td.run(2);
	_td.run(10);
	_td.run(11);
	$display("CLAA task:");
	repeat (10) begin
		claa.run($urandom, $urandom);
	end
	$display("CSA_S task:");
	repeat (10) begin
		csa_s.run($urandom, $urandom);
	end
	$display("fast_comparator task:");
	fc.run(2, 1);
	fc.run(1, 2);
	fc.run(15, 14);
	fc.run(12, 13);
	fc.run(11, 11);
	fc.run(20, 78);
	fc.run(123, 100);
	$display("polyshift_r task:");
	psr.run(8'b11001100, 7'b0101010);
	$display("polyshift_l task:");
	psl.run(8'b00110011, 7'b1010101);
	$display("RCA_M task:");
	repeat (10) begin
		rca_m.run($urandom, $urandom);
	end
end
endmodule