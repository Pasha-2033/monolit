module task_r2s_sync;
logic[7:0] data_slow = 8'b10100101;
logic clk_fast = '1;
logic clk_slow = '0;
logic reset;
wire sig_out;
always #1 clk_fast = ~clk_fast;
always #5 clk_slow = ~clk_slow;
r2s_sync fc (
  .clk_dst_i(clk_fast),
  .arst_i(reset),
  .sig_i(data_slow[0]), 
  .sig_o(sig_out)  
);
always_ff @(posedge clk_slow) begin
	data_slow <= {1'b0, data_slow[7:1]};
end
task run();
    begin
      reset = 1;
      #1;
      $display("Time = %0t, sig_out = %b (сброс)", $time, sig_out);
      reset = 0;

      // Читаем первый бит (начальный) – ждём два такта clk_fast (4 ед.) + 0.5 нс,
      // чтобы попасть между обновлением sig_out (в t=4) и изменением данных (в t=5)
      #3.5;   // t = 1 + 3.5 = 4.5
      $display("Time = %0t, bit 0 = %b", $time, sig_out);   // ожидается 1

      // Второй бит – изменение данных произошло в t=5, задержка 4 ед. → читаем в t=9
      #4.5;   // t = 4.5 + 4.5 = 9
      $display("Time = %0t, bit 1 = %b", $time, sig_out);   // ожидается 0

      // Остальные биты 2..7 – каждые 10 ед. после изменения и задержки
      for (int i = 2; i < 8; i++) begin
        #10;   // t = 19, 29, 39, 49, 59, 69
        $display("Time = %0t, bit %0d = %b", $time, i, sig_out);
      end
    end
  endtask
endmodule