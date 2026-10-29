::iverilog -g2012 -I .. -I utils_tasks -o out utils_tb.sv
::iverilog -g2012 -I .. -I io_tasks -o out io_tb.sv
iverilog -g2012 -I .. -I timers_tasks -o out timers_tb.sv
gtkwave out.vcd
::del out.vcd
pause