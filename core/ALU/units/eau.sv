//extended arithmetic unit
module EAU (
	input	wire				CF_i,
	input	wire	[3:0]		is_sub_i,
	input	wire	[3:0][1:0]	sub_unit_control_i,	//adder CF selection

	input	wire	[3:0][7:0]	a_i,
	input	wire	[3:0][7:0]	b_i,
	input	wire	[3:0][7:0]	not_a_i,
	output	wire	[3:0][7:0]	r_o,

	output	wire	[4:0]    	CF_o
);
wire [3:0] g_to_la;
wire [3:0] p_to_la;
wire [3:0] cf_from_la;
wire [3:0][3:0] claa_cf_pre_args;
wire [3:0] claa_cf_args;
wire [3:0][7:0] a_to_adder;
wire [3:0][7:0] r_from_adder;
assign claa_cf_pre_args[0][2] = '1;
assign claa_cf_pre_args[1][2] = CF_o[0];
assign claa_cf_pre_args[2][2] = CF_o[1];
assign claa_cf_pre_args[3][2] = CF_o[2];
genvar i;
generate
	for (i = 0; i < 4; ++i) begin : arg
		assign a_to_adder[i] = is_sub_i[i] ? not_a_i[i] : a_i[i];

		assign r_o[i] = is_sub_i[i] ? ~r_from_adder[i] : r_from_adder[i];

		assign claa_cf_pre_args[i][0] = cf_from_la[i];
		assign claa_cf_pre_args[i][1] = '0;
		assign claa_cf_pre_args[i][3] = CF_i;
		assign claa_cf_args[i] = claa_cf_pre_args[i][sub_unit_control_i[i]];
	end
endgenerate
_LA #(.CASCADE_SIZE(4)) la (
	.c_i(CF_i),
	.p_i(p_to_la),
	.g_i(g_to_la),
	.c_o({CF_o[4], cf_from_la})
	//ingore technical outupts P & G
);
CLAA #(.WORD_WIDTH(8)) claa [3:0] (
	.c_i(claa_cf_args), 
	.a_i(a_to_adder), 
	.b_i(b_i),
	.r_o(r_from_adder),
	.pg_o(p_to_la),
	.gg_o(g_to_la),
	.c_o(CF_o[3:0])
);
endmodule