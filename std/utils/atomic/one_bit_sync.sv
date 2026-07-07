//currently 2-stages, for very fast lock should be 3-stages (10^-30 failures per second)
module one_bit_2s_sync (
	input	wire	clk_dst_i,
    input	wire	arst_i,
    input	wire	sig_i, 
    output	reg		sig_o     
);
reg meta;
always_ff @(posedge clk_dst_i or posedge arst_i) begin
	if (arst_i) begin
		meta <= '0;
		sig_o <= '0;
	end else begin
		meta <= sig_i;
		sig_o <= meta;
	end
end
endmodule