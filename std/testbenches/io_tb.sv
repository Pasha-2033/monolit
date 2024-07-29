`include "io.sv"
`include "SPI.sv"
`timescale 1ps/1ps
module io_tb;
task_SPI #(.word_width(8), .SS_width(1)) spi();
initial begin
	$display("as master");
	spi.run_as_master(8'b00110011, 8'b10101010, 1'b1);
	$display("as slave");
	spi.run_as_slave(8'b00110011, 8'b10101010, 1'b0);
end
endmodule