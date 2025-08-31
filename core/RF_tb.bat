iverilog -g2012 -I ../std -I utils_tasks -o out RF_tb.sv
vvp out
del out
pause