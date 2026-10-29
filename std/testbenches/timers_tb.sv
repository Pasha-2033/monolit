`include "utils.sv"
`include "timers.sv"
`include "PIT.sv"
`include "GPT.sv"
module timers_tb;
timeunit 1ns;          // единица времени – наносекунды
timeprecision 100ps;   // точность 0.1 нс – разрешает дробные задержки
task_PIT pit();
task_MONO_GPT mono_gpt();
task_POLY_GPT poly_gpt();
initial begin
	//$display("PIT");
	//pit.run();
	//$display("MONO GPT");
	//mono_gpt.run();
	$display("POLY GPT");
	poly_gpt.run();
end
endmodule