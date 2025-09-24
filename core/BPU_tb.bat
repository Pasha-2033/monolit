iverilog -g2012 -I ../std -o out BPU_tb.sv
vvp out
del out
pause