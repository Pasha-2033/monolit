module task_async_queue;
logic wclk = '0;
logic rclk = '0;
logic reset;
logic we;
logic re;
logic [7:0][7:0] data_i;
wire [7:0] data_o;
wire is_full_o;
wire almost_full_o;
wire is_empty_o;
wire almost_empty_o;

always #3 wclk = ~wclk;
always #7 rclk = ~rclk;

async_queue #(.WORD_WIDTH(8), .ADDRESS_WIDTH(3), .ALMOST_FULL_THRESHOLD(2), .ALMOST_EMPTY_THRESHOLD(3)) queue (
	.w_clk_i(wclk),
	.r_clk_i(rclk),
	.arst_i(reset),

	.we_i(we),	//write enable
	.re_i(re),	//read enable

	.data_i(data_i[0]),
	.data_o(data_o),

	.is_full_o(is_full_o),
	.almost_full_o(almost_full_o),
	.is_empty_o(is_empty_o),
	.almost_empty_o(almost_empty_o)
);
int i;
int ii;
task run();
	data_i = { 8'hA5, 8'h5A, 8'h00, 8'hFF, 8'hA5, 8'h5A, 8'h00, 8'hFF };
    // Сброс
    reset = 1;
    we = 0;
    re = 0;
    repeat (3) @(posedge wclk);
    reset = 0;
    @(posedge wclk);
    $display("Reset done");

    // Запись всех байт – выводим то, что подаём на вход
    we = 1;
    re = 0;
    for (i = 0; i < $size(data_i); i++) begin
        @(posedge wclk);
        $display("W! D_in: %h, F: %b, AF: %b, E: %b, AE: %b", 
                 data_i[0], is_full_o, almost_full_o, is_empty_o, almost_empty_o);
        // Сдвиг для следующего такта
        data_i <= {8'd0, data_i[7:1]};
    end

    we = 0;

    // Небольшая задержка для завершения синхронизации указателей
    repeat (10) begin
		@(posedge wclk);
		$display("O! D_in: %h, F: %b, AF: %b, E: %b, AE: %b", data_i[0], is_full_o, almost_full_o, is_empty_o, almost_empty_o);
	end
	$display("Write phase finished");

    // Чтение всех байт
    re = 1;
    for (i = 0; i < $size(data_i); i++) begin
        @(posedge rclk);
        $display("R! D_out: %h, F: %b, AF: %b, E: %b, AE: %b", 
                 data_o, is_full_o, almost_full_o, is_empty_o, almost_empty_o);
    end
    re = 0;
    //repeat (5) @(posedge rclk);
    $display("Read phase finished");
	repeat (10) begin
		@(posedge rclk);
		$display("O! D_in: %h, F: %b, AF: %b, E: %b, AE: %b", data_i[0], is_full_o, almost_full_o, is_empty_o, almost_empty_o);
	end
endtask
task arun();
	data_i = { 8'hA5, 8'h5A, 8'h00, 8'hFF, 8'hA5, 8'h5A, 8'h00, 8'hFF };
	// Сброс
	reset = 1;
	we = 0;
	re = 0;
	repeat (3) @(posedge wclk);
	reset = 0;
	@(posedge wclk);
	$display("Reset done");
	fork
		begin
			we = 1;
			for (i = 0; i < $size(data_i); i++) begin
				@(posedge wclk);
				//$display("W! D_in: %h, F: %b, AF: %b, E: %b, AE: %b", data_i[0], is_full_o, almost_full_o, is_empty_o, almost_empty_o);
				// Сдвиг для следующего такта
				data_i <= {8'd0, data_i[7:1]};
			end
			we = 0;
		end
		begin
			repeat (2) @(posedge rclk);
			re = 1;
			for (ii = 0; ii < $size(data_i); ++ii) begin
				@(posedge rclk);
				$display("R! D_out: %h, F: %b, AF: %b, E: %b, AE: %b", data_o, is_full_o, almost_full_o, is_empty_o, almost_empty_o);
			end
			re = 0;
		end
	join
endtask
endmodule