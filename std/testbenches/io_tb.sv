`include "io.sv"
`include "SPI_X_slave.sv"
`include "SPI_X_BUF_master.sv"
`include "UART_RX.sv"
`include "UART_TX.sv"
`include "UART.sv"
`timescale 1ps/1ps
module io_tb;
//task_SPI #(.word_width(8), .send_width(1), .SS_width(1)) spi();
task_UART_RX rx();
task_UART_TX tx();
task_UART_as_RX uart_rx();
task_UART_as_TX uart_tx();
task_SPI_X_slave spi_x_slave();
task_SPI_X_BUF_master spi_x_buf_master();
initial begin
	//$display("as master");
	//spi.run_as_master(8'b00110011, 8'b10101010, 1'b0);
	//$display("as slave");
	//spi.run_as_slave(8'b00110011, 8'b10101010, 1'b0);
	//$display("RX");
	//rx.run();
	//$display("TX");
	//tx.run();
	//$display("UART RX");
	//uart_rx.run_RX();
	//$display("UART TX");
	//uart_tx.run_TX();
	//$display("SPI_X slave");
	//spi_x_slave.run();
	$display("SPI_X_BUF_master");
	spi_x_buf_master.run();
end
endmodule