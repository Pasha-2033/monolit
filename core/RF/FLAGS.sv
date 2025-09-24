package flag_indexes;
	//system flags (0-15)
	parameter KF_INDEX = 0;		//kernel mode
	//executable flags (16-31)
	parameter CF_INDEX = 16;	//carry flag
	parameter ZF_INDEX = 17;	//zero flag
	parameter OF_INDEX = 18;	//overflow flag
	parameter SF_INDEX = 19;	//sign flag
	parameter PF_INDEX = 20;	//parity flag
endpackage
module FLAGS (
	input	wire			clk_i,
	input	wire			arst_i,
	input	wire			to_kernel,
	input	wire	[31:0]	flags_i,
	output	reg		[31:0]	flags_o
);
always_ff @(posedge clk_i or posedge arst_i) begin
	if (arst_i) begin
		//system flags
		flags_o[flag_indexes::KF_INDEX] <= '1;	//reset to kernel mode
		flags_o[15:1] <= '0;	//temp solution
		//executable flags
		flags_o[flag_indexes::CF_INDEX] <= '0;
		flags_o[flag_indexes::ZF_INDEX] <= '0;
		flags_o[flag_indexes::OF_INDEX] <= '0;
		flags_o[flag_indexes::SF_INDEX] <= '0;
		flags_o[flag_indexes::PF_INDEX] <= '0;
		flags_o[31:21] <= '0;	//temp solution
	end else begin
		if (flags_o[flag_indexes::KF_INDEX]) begin
			flags_o[15:0] <= flags_i[15:0];
		end else begin
			flags_o[flag_indexes::KF_INDEX] <= to_kernel;
		end
		flags_o[31:16] <= flags_i[31:16];
	end
end
endmodule