`include "io.sv"
`include "SPI.sv"
`include "UART_RX.sv"
`include "UART_TX.sv"
`timescale 1ps/1ps
module io_tb;
task_SPI #(.word_width(8), .send_width(1), .SS_width(1)) spi();
task_UART_RX rx();
task_UART_TX tx();
initial begin
	$display("as master");
	spi.run_as_master(8'b00110011, 8'b10101010, 1'b0);
	$display("as slave");
	spi.run_as_slave(8'b00110011, 8'b10101010, 1'b0);
	$display("RX");
	rx.run();
	$display("TX");
	tx.run();
end
endmodule