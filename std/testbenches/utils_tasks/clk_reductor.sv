module task_const_clk_reductor;
logic clk = '0;
logic reset;
wire out;

always #10 clk = ~clk;

const_clk_reductor #(.REDUCTION(3)) red (
	.arst_i(reset),
	.clk_i(clk),
	.clk_o(out)
);
task run;
	begin
		reset = '1;
		#5
		reset = '0;
		$display("%b", out);
		repeat (50) begin
			#20
			$display("%b", out);
		end
	end
endtask
endmodule