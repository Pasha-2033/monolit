iverilog -g2012 -I ../std -o out _C_tb.sv
vvp out
del out
pause