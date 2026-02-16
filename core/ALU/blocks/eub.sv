//extended unit flags
module EUF (
	input	wire	[3:0]		a_end_i,
	input	wire	[3:0][7:0]	r_i,

	input	wire	[1:0]		CF_sel_i,
	input	wire	[1:0]		ZF_sel_i,
	input	wire	[1:0]		SF_sel_i,
	input	wire	[1:0]		PF_sel_i,
	input	wire	[1:0]		OF_sel_i,

	input	wire	[3:0]		CF_i,

	output	wire				CF_o,
	output	wire				ZF_o,
	output	wire				SF_o,
	output	wire				PF_o,
	output	wire				OF_o
);
///////////////////////////////
//expected sceme:            //
//{8x+,8x,8x,8x}             //
//{(8x+,8x)/16x,16x+}        //
//{8x+,24+}                  //
//{32x+}                     //
//where "+" means ZF/PF used //
///////////////////////////////
wire [3:0] ZF_basic_array;
wire [3:0] ZF_array;
wire [3:0] SF_array;
wire [3:0] PF_array;
wire [3:0] OF_array;
integer i;
always_comb begin
	ZF_array = {
		|ZF_basic_array,
		|ZF_basic_array[2:0],
		|ZF_basic_array[1:0],
		ZF_basic_array[3]
	};
	for (i = 0; i < 4; ++i) begin
		ZF_basic_array[i] = |r_i[i];
		SF_array[i] = r_i[i][7];
		PF_array[i] = r_i[i][0];
		OF_array[i] = a_end_i[i] ^ SF_array[i];
	end
	CF_o = CF_i[CF_sel_i];
	ZF_o = ZF_array[ZF_sel_i];
	SF_o = SF_array[SF_sel_i];
	PF_o = PF_array[PF_sel_i];
	OF_o = OF_array[OF_sel_i];
end
endmodule
//extended arithmetic block
module EAB (
	input	wire				CF_i,
	input	wire	[3:0]		is_sub_i,
	input	wire	[3:0][1:0]	sub_unit_control_i,

	input	wire	[3:0][7:0]	a_i,
	input	wire	[3:0][7:0]	b_i,
	output	wire	[3:0][7:0]	r_o,

	input	wire	[1:0]		CF_sel_i,
	input	wire	[1:0]		ZF_sel_i,
	input	wire	[1:0]		SF_sel_i,
	input	wire	[1:0]		PF_sel_i,
	input	wire	[1:0]		OF_sel_i,

	output	wire				CF_o,
	output	wire				ZF_o,
	output	wire				SF_o,
	output	wire				PF_o,
	output	wire				OF_o
);
wire [4:0] CF_from_unit;
EAU unit (
	.CF_i(CF_i),
	.is_sub_i(is_sub_i),
	.sub_unit_control_i(sub_unit_control_i),

	.a_i(a_i),
	.b_i(b_i),
	.not_b_i(~b_i),
	.r_o(r_o),

	.CF_o(CF_from_unit)
);
EUF flags (
	.a_end_i({a_i[3][7], a_i[2][7], a_i[1][7], a_i[0][7]}),
	.r_i(r_o),

	.CF_sel_i(CF_sel_i),
	.ZF_sel_i(ZF_sel_i),
	.SF_sel_i(SF_sel_i),
	.PF_sel_i(PF_sel_i),
	.OF_sel_i(OF_sel_i),

	.CF_i(CF_from_unit[3:0]),

	.CF_o(CF_o),
	.ZF_o(ZF_o),
	.SF_o(SF_o),
	.PF_o(PF_o),
	.OF_o(OF_o)
);
endmodule