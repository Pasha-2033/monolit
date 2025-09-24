iverilog -g2012 -I ../std -o out RF_tb.sv
vvp out
del out
pause