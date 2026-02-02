`include "utils.sv"
`include "tree_decoder.sv"
`include "CLAA.sv"
`include "CSA_S.sv"
`include "fast_comparator.sv"
`include "polyshift_r.sv"
`include "polyshift_l.sv"
`include "RCA_M.sv"
`include "screening_by_junior.sv"
`include "screening_by_senior.sv"
`include "counter.sv"
`include "counter_forward.sv"
`include "counter_backward.sv"
`timescale 1ps/1ps
module utils_tb;
task_tree_decoder #(.OUTPUT_WIDTH(12)) td();
task_CLAA #(.WORD_WIDTH(16)) claa();
task_CSA_S #(.WORD_WIDTH(12), .UNIT_WIDTH(5)) csa_s();
task_fast_comparator #(.WORD_WIDTH(6)) fc();
task_polyshift_r #(.WORD_WIDTH(8)) psr();
task_polyshift_l #(.WORD_WIDTH(8)) psl();
task_RCA_M #(.WORD_WIDTH(16)) rca_m();
task_screening_by_junior #(.WORD_WIDTH(8)) sbj();
task_screening_by_senior #(.WORD_WIDTH(8)) sbs();
task_counter #(.WORD_WIDTH(8)) tcc();
task_counter_forward #(.WORD_WIDTH(8)) tcf();
task_counter_backward #(.WORD_WIDTH(8)) tcb();
initial begin
	/*
	$display("_tree_decoder task:");
	td.run(0);
	td.run(1);
	td.run(2);
	td.run(10);
	td.run(11);
	$display("CLAA task:");
	repeat (10) begin
		claa.run($urandom, $urandom);
	end
	$display("CSA_S task:");
	repeat (10) begin
		csa_s.run($urandom, $urandom);
	end*/
	$display("fast_comparator task:");
	repeat (100000) begin
		fc.run($urandom, $urandom);
	end
	$display("END");

	/*
	$display("polyshift_r task:");
	psr.run(8'b11001100, 7'b0101010);
	$display("polyshift_l task:");
	psl.run(8'b00110011, 7'b1010101);
	$display("RCA_M task:");
	repeat (10) begin
		rca_m.run($urandom, $urandom);
	end
	$display("screening_by_junior task:");
	repeat (10) begin
		sbj.run($urandom);
	end
	$display("screening_by_senior task:");
	repeat (10) begin
		sbs.run($urandom);
	end
	$display("counter task:");
	tcc.run();
	$display("counter forward task:");
	tcf.run();
	$display("counter backward task:");
	tcb.run();
	*/
end
endmodule