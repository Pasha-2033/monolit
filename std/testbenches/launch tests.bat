iverilog -g2012 -I .. -I utils_tasks -o out utils_tb.sv
vvp out
del out
pause