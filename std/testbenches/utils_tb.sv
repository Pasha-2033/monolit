`include "utils.sv"
`include "fast_adder.sv"
`include "polyshift_r.sv"
`include "polyshift_l.sv"
`timescale 1ps/1ps
module utils_tb;
task_fast_adder #(.cascade_size(4), .word_width(16)) fa ();
task_polyshift_r #(.word_width(8)) psr();
task_polyshift_l #(.word_width(8)) psl();
initial begin
	$display("fast_adder task:");
	fa.run(10, 20);
	$display("polyshift_r task:");
	psr.run(8'b11001100, 7'b0101010);
	$display("polyshift_l task:");
	psl.run(8'b00110011, 7'b1010101);
end
endmodule