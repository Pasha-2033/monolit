//extended arithmetic unit
module EAU (
	input	wire				CF_i,
	input	wire	[3:0]		is_sub_i,
	input	wire	[3:0][1:0]	sub_unit_control_i,	//adder CF selection

	input	wire	[3:0][7:0]	a_i,
	input	wire	[3:0][7:0]	b_i,
	input	wire	[3:0][7:0]	not_b_i,
	output	wire	[3:0][7:0]	r_o,

	output	wire	[4:0]    	CF_o
);
wire [3:0] g_to_la;
wire [3:0] p_to_la;
wire [3:0] cf_from_la;
wire [3:0][3:0] claa_cf_pre_args;
wire [3:0] claa_cf_args;
wire [3:0][7:0] b_to_adder;
wire [3:0][7:0] b_from_adder;
integer i;
always_comb begin
	claa_cf_pre_args[0][2] = '1;
	claa_cf_pre_args[1][2] = CF_o[0];
	claa_cf_pre_args[2][2] = CF_o[1];
	claa_cf_pre_args[3][2] = CF_o[2];
	for (i = 0; i < 4; ++i) begin : arg
		b_to_adder[i] = is_sub_i[i] ? not_b_i[i] : b_i[i];

		r_o[i] = is_sub_i[i] ? ~b_from_adder[i] : b_from_adder[i];

		claa_cf_pre_args[i][0] = cf_from_la[i];
		claa_cf_pre_args[i][1] = '0;
		claa_cf_pre_args[i][3] = CF_i;
		claa_cf_args[i] = claa_cf_pre_args[i][sub_unit_control_i[i]];
	end
end
_LA #(.CASCADE_SIZE(4)) la (
	.c_i(CF_i),
	.p_i(p_to_la),
	.g_i(g_to_la),
	.c_o({CF_o[4], cf_from_la})
	//ingore technical outupts P & G
);
CLAA #(.WORD_WIDTH(8)) claa [3:0] (
	.c_i(claa_cf_args), 
	.a_i(a_i), 
	.b_i(b_to_adder),
	.r_o(b_from_adder),
	.pg_o(p_to_la),
	.gg_o(g_to_la),
	.c_o(CF_o[3:0])
);
endmodule