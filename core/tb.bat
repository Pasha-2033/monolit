iverilog -g2012 -I ../std -I utils_tasks -o out RF_tb.sv
::iverilog -g2012 -I .. -I io_tasks -o out io_tb.sv
vvp out
del out
pause