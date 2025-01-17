`define STD_UTILS
`define min(a, b) ((a) > (b) ? (b) : (a))
`define max(a, b) ((a) > (b) ? (a) : (b))

/*
Will reverse word bitwise (DCBA->ABCD).
Parameters:
	word_width - width of input and output word
Ports:
	in	- word to reverse
	out	- reversed word
Generation:
	assign junior bits to senior ones and senior bits to junior ones
*/
module bit_reverse #(
	parameter word_width
) (
	input	wire [word_width - 1:0] in,
	output	wire [word_width - 1:0] out
);
for(genvar i = 0; i < word_width; ++i) begin: reverse
	assign out[i] = in[word_width - i - 1];
end
endmodule
/*
Will create ripple carry adder improved by Manchester carry chain
*/
module RCA_M #(
	parameter word_width
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire					C_OUT
);
wire [word_width:0] C;
wire [word_width - 1:0] OR = A | B;
wire [word_width - 1:0] AND = A & B;
wire [word_width - 1:0] XOR = OR & ~AND;
assign R = XOR ^ C;
assign C[0] = C_IN;
assign C_OUT = C[word_width];
for (genvar i = 0; i < word_width; ++i) begin: RCA_unit
	assign C[i + 1] = XOR[i] ? C[i] : AND[i];
end
endmodule




/*
Will create lookahead for CLAA
Ports:
	C_IN	- carry input
	P		- propagation
	G		- generation
	C		- carry for CLAA units
	PG		- propagation group
	GG		- generation group
*/
module _LA #(
	parameter cascade_size
) (
	input	wire						C_IN,
	input	wire [cascade_size - 1:0]	P,
	input	wire [cascade_size - 1:0]	G,
	output	wire [cascade_size:0]		C,
	output	wire						PG,
	output	wire						GG
);
wire [cascade_size - 1:0] PRE_GG;
assign C = {G | (P & C[cascade_size - 1:0]), C_IN};
assign PG = &P;
assign GG = |PRE_GG;
//lookahead implementation
for(genvar i = 0; i < cascade_size; ++i) begin: signal_cascade
	if (i == cascade_size - 1) begin
		assign PRE_GG[i] = G[i];
	end else begin
		assign PRE_GG[i] = G[i] & (&P[cascade_size - 1:i + 1]);
	end 
end
endmodule
/*
Will create carry-lookahead adder (faster addition operation).
Parameters:
	word_width		- width of operands and result
	cascade_size	- number of fast adders in lower level
Local parameters:
	cascade_num	- word_width of lower level fast adders
Ports:
	C_IN	- carry input
	A		- A operand
	B		- B operand
	R		- result
	PG		- propagation group
	GG		- generation group
	C_OUT	- carry output
Generation:
	CLAA is recusrsive module
	if word_width > cascade_size then lookahead and lower level is generated
	else ripple-carry adder is generated
	lower level is smaller fast adders
*/
module CLAA #(
	parameter cascade_size = 4,
	parameter word_width = 4
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire					PG,
	output	wire					GG,
	output	wire					C_OUT
);
localparam cascade_num = word_width / cascade_size;
wire [cascade_size - 1:0] P;
wire [cascade_size - 1:0] G;
wire [cascade_size - 1:0] C;
genvar i;
genvar j;
if (cascade_num > 1) begin
	//creating lowest level
	CLAA #(.cascade_size(cascade_size), .word_width(cascade_num)) child_CLAA [cascade_size - 1:0] (
		.C_IN(C[cascade_num - 1:0]),
		.A(A),
		.B(B),
		.R(R),
		.PG(P),
		.GG(G)
	);
end else begin
	//lowest level implementation
	assign P = A | B;
	assign G = A & B;
	assign R = (P & ~G) ^ C;
end
//lookahead implementation
_LA #(.cascade_size(cascade_size)) lookahead (
	.C_IN(C_IN),
	.P(P),
	.G(G),
	.C({C_OUT, C}),
	.PG(PG),
	.GG(GG)
);
endmodule



/*
Will create carry-select unit for CSA.
TODO: check
*/
module _CSA_U #(
	parameter word_width
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire 					C_OUT
);
wire [1:0] PRE_C_OUT;
wire [1:0][word_width - 1:0] PRE_R;
assign C_OUT = PRE_C_OUT[C_IN];
assign R = PRE_R[C_IN];
//adders (TODO), RCA_M is temp(?)
RCA_M #(.word_width(word_width)) adders [1:0] (
	.C_IN({1'b1, 1'b0}),
	.A({A, A}),
	.B({B, B}),
	.R(PRE_R),
	.C_OUT(PRE_C_OUT)
);
endmodule
/*
static size carry select adder
TODO: check and test
*/
module CSA_S #(
	parameter unit_width,
	parameter word_width
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire 					C_OUT
);
localparam full_size = 2 ** $clog2(word_width);
localparam junior_reduction = full_size - word_width;
localparam csa_units_num = full_size / unit_width;
wire [csa_units_num - 1:0] ALL_C; //...
assign C_OUT = ALL_C[csa_units_num - 1]; //...
RCA_M #(.word_width(unit_width - 1)) junior_adder ( //...
	.C_IN(C_IN),
	.A(A[unit_width - 2:0]), //...
	.B(B[unit_width - 2:0]), //...
	.R(R[unit_width - 2:0]), //...
	.C_OUT(ALL_C[0])
);
if (csa_units_num > 1) begin
	_CSA_U #(.word_width(unit_width)) selection_unit [csa_units_num - 2:0] ( //...
		.C_IN(ALL_C[csa_units_num - 2:0]), //...
		.A(A[word_width - 1:unit_width - 1]), //...
		.B(B[word_width - 1:unit_width - 1]), //...
		.R(R[word_width - 1:unit_width - 2]), //...
		.C_OUT(ALL_C[csa_units_num - 1:1]) //...
	);
end
endmodule
/*
dynamic size carry select adder
*/
module CSA_D #(
	parameter unit_width,
	parameter word_width
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire 					C_OUT
);
//TODO
endmodule
//TODO сумматор с условным переносом это 3 сумматора (младшие, 2 старших (Cin = 0 и 1))
//младший сумматор выбирает какой из старших подет в ответ
//то есть старшие это почти что CSA


/*
Provides fast comparator.
Parameters:
	word_width	- width of operand
Ports:
	A			- A operand
	B			- B operand
	above		- if A > B
	below		- if A < B
*/
//equal = ~(above | below)
module fast_comparator #(
	parameter word_width
) (
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire above,
	output	wire below
);
wire [word_width - 1:0] pre_above = A & ~B;
wire [word_width - 1:0] pre_below = ~A & B;
if (word_width > 1) begin
	localparam i_limit = $clog2(word_width) - 1;
	localparam cv = 2 ** (i_limit + 1) - word_width;
	wire [2 ** (i_limit + 1) - 2:0] above_tree;
	wire [2 ** (i_limit + 1) - 2:0] below_tree;
	assign above = above_tree[0];
	assign below = below_tree[0];
	for (genvar i = 0; i < i_limit; ++i) begin : compare_lvl
		localparam size = 2 ** i;
		localparam senior = size * 2 - 1;
		localparam junior = senior * 2;
		assign above_tree[size - 1+:size] = above_tree[junior-:size] | (above_tree[senior+:size] & ~below_tree[junior-:size]);
		assign below_tree[size - 1+:size] = below_tree[junior-:size] | (~above_tree[junior-:size] & below_tree[senior+:size]);
	end
	localparam size = 2 ** i_limit;
	assign above_tree[size - 1+:size - cv] = pre_above[word_width - cv - 1-:size - cv] | (pre_above[size - 1:0] & ~pre_below[word_width - cv - 1-:size - cv]);
	assign below_tree[size - 1+:size - cv] = pre_below[word_width - cv - 1-:size - cv] | (~pre_above[word_width - cv - 1-:size - cv] & pre_below[size - 1:0]);
	if (cv) begin
		assign above_tree[2 ** (i_limit + 1) - 2-:cv] = pre_above[word_width - 1-:cv];
		assign below_tree[2 ** (i_limit + 1) - 2-:cv] = pre_below[word_width - 1-:cv];
	end
end else begin
	assign above = pre_above;
	assign below = pre_below;
end
endmodule
//CARRY is a special case of DOUBLE_PRECISION
typedef enum bit[1:0] {LOGIC, ARITHMETIC, DOUBLE_PRECISION, CYCLIC} SHIFT_TYPE;
//NOTE: RCR is usually uses $size(C_IN) = 1
//WARNING: DO NOT SET $size(C_IN) >= $size(D_IN)!
`define RCR(D_IN, C_IN) {D_IN[$size(D_IN) - 1:$size(C_IN)], C_IN}
/*
Provides all right shifts.
Parameters:
	word_width	- width of operand and result
Ports:
	C_IN		- placing bits (for DOUBLE_PRECISION)
	D_IN		- word to shift
	shift_size	- number of bits to shift
	shift_type	- type of shift (see SHIFT_TYPE)
	D_OUT		- shifted word
Generation:
	scheme contains mode multiplexer and shift multiplexer
	first one is placing bits selection (according to shift_type)
	second one is selection of shift size (all shifted words are generated and used for selection)
*/
module polyshift_r #(
	parameter word_width
) (
	input wire [word_width - 2:0] C_IN,
	input wire [word_width - 1:0] D_IN,
	input wire [$clog2(word_width) - 1:0] shift_size,
	input wire [1:0] shift_type,
	output wire [word_width - 1:0] D_OUT
);
wire [3:0][word_width - 2:0] shift_args = {
	D_IN[word_width - 2:0],						//CYCLIC,
	C_IN,										//DOUBLE_PRECISION
	{word_width - 1{D_IN[word_width - 1]}},		//ARITHMETIC
	{word_width - 1{1'b0}}						//LOGIC
};
wire [word_width - 2:0] shift_arg = shift_args[shift_type];
wire [word_width - 1:0][word_width - 1:0] shift_input;
assign shift_input[0] = D_IN;
assign D_OUT = shift_input[shift_size];
for(genvar i = 1; i < word_width; ++i) begin: input_generation
	assign shift_input[i] = {shift_arg[i - 1:0], D_IN[word_width - 1:i]};
end
endmodule
//NOTE: RCL is usually uses $size(C_IN) = 1
//WARNING: DO NOT SET $size(C_IN) >= $size(D_IN)!
`define RCL(D_IN, C_IN) {C_IN, D_IN[$size(D_IN) - 1:$size(C_IN)]}
/*
Provides all left shifts.
Parameters:
	word_width	- width of operand and result
Ports:
	C_IN		- placing bits (for DOUBLE_PRECISION)
	D_IN		- word to shift
	shift_size	- number of bits to shift
	shift_type	- type of shift (see SHIFT_TYPE)
	D_OUT		- shifted word
Generation:
	scheme contains mode multiplexer and shift multiplexer
	first one is placing bits selection (according to shift_type)
	second one is selection of shift size (all shifted words are generated and used for selection)
*/
module polyshift_l #(
	parameter word_width
) (
	input wire [word_width - 2:0] C_IN,
	input wire [word_width - 1:0] D_IN,
	input wire [$clog2(word_width) - 1:0] shift_size,
	input wire [1:0] shift_type,
	output wire [word_width - 1:0] D_OUT
);
wire [3:0][word_width - 2:0] shift_args = {
	D_IN[word_width - 1:1],		//CYCLIC,
	C_IN,						//DOUBLE_PRECISION
	{word_width - 1{1'b0}},		//ARITHMETIC (may be put '1??? because it`s looks like LOGIC)
	{word_width - 1{1'b0}}		//LOGIC
};
wire [word_width - 2:0] shift_arg = shift_args[shift_type];
wire [word_width - 1:0][word_width - 1:0] shift_input;
assign shift_input[0] = D_IN;
assign D_OUT = shift_input[shift_size];
for(genvar i = 1; i < word_width; ++i) begin: input_generation
	assign shift_input[i] = {D_IN[word_width - i - 1:0], shift_arg[word_width - 2:word_width - i - 1]};
end
endmodule
/*
Provides counter with builded in adder and subtractor.
Parameters:
	word_width	- width of counter value and value for loading
Ports:
	clk				- clock
	count			- enable counting
	load			- enable loading
	reset			- reset asynchronously
	D_IN			- data for loading
	D_OUT			- counter value
	will_overflow	- shows if next count will be with overflow
Generation:
	count = 0 & load = 0 - do nothing
	count = 0 & load = 1 - load
	count = 1 & load = 0 - count up
	count = 1 & load = 1 - count down
*/
module counter #(
	parameter word_width
) (
	input	wire					clk,
	input	wire					count,
	input	wire					load,
	input	wire					reset,
	input	wire [word_width - 1:0]	D_IN,
	output	reg  [word_width - 1:0]	D_OUT,
	output	wire					will_overflow
);
wire [word_width - 1:0] load_flow = {load_flow[word_width - 2:0] & ~D_OUT[word_width - 2:0], count & load};
wire [word_width - 1:0] count_flow = {count_flow[word_width - 2:0] & D_OUT[word_width - 2:0], ~load_flow[0]};
assign will_overflow = &(load_flow[0] ? ~D_OUT : D_OUT);
always @(posedge clk or posedge reset) begin
	if (reset) begin
		D_OUT <= '0;
	end else if (count | load) begin
		D_OUT <= ~count & load ? D_IN : {D_OUT[word_width - 1:1] ^ (count_flow[word_width - 1:1] | load_flow[word_width - 1:1]), ~D_OUT[0]};
	end
end
endmodule
/*
Provides counter with builded in adder.
Parameters:
	word_width	- width of counter value and value for loading
Ports:
	clk				- clock
	action			- select action type
	reset			- reset asynchronously
	D_IN			- data for loading
	D_OUT			- counter value
	will_overflow	- shows if next count will be with overflow
Generation:
	action = 0	- count up
	action = 1	- load
*/
module counter_forward #(
	parameter word_width
) (
	input	wire					clk,
	input	wire					action,
	input	wire					reset,
	input	wire [word_width - 1:0]	D_IN,
	output	reg  [word_width - 1:0]	D_OUT,
	output	wire					will_overflow
);
wire [word_width - 2:0] count_flow = {count_flow[word_width - 3:0] & D_OUT[word_width - 2:1], D_OUT[0]};
assign will_overflow = &D_OUT;
always_ff @(posedge clk or posedge reset) begin
	if (reset) begin
		D_OUT <= '0;
	end else begin
		D_OUT <= action ? D_IN : {D_OUT[word_width - 1:1] ^ count_flow, ~D_OUT[0]};
	end
end
endmodule
/*
Provides counter with builded in subtractor.
Parameters:
	word_width	- width of counter value and value for loading
Ports:
	clk				- clock
	action			- select action type
	reset			- reset asynchronously
	D_IN			- data for loading
	D_OUT			- counter value
	will_overflow	- shows if next count will be with overflow
Generation:
	action = 0	- count down
	action = 1	- load
*/
module counter_backward #(
	parameter word_width
) (
	input	wire					clk,
	input	wire					action,
	input	wire					reset,
	input	wire [word_width - 1:0]	D_IN,
	output	reg  [word_width - 1:0]	D_OUT,
	output	wire					will_overflow
);
wire [word_width - 2:0] load_flow = {load_flow[word_width - 3:0] | D_OUT[word_width - 2:1], D_OUT[0]};
assign will_overflow = ~|D_OUT;
always_ff @(posedge clk or posedge reset) begin
	if (reset) begin
		D_OUT <= '0;
	end else begin
		D_OUT <= action ? D_IN : {D_OUT[word_width - 1:1] ^ ~load_flow, ~D_OUT[0]};
	end
end
endmodule
/*
Provides decoder.
Parameters:
	output_width - number of out bits (also defines width of select)
Ports:
	select	- value to decode
	out		- decoded value
Notes:
	it supports non 2^n outputs, so it won`t overgenerate
	it`s not reccomended to decode with large output_width (it will generate multiple large AND), use predecoding instead
*/
module _array_decoder #(
	parameter output_width
) (
	input	wire [$clog2(`max(output_width, 2)) - 1:0] select,
	output	wire [output_width - 1:0] out
);
if (output_width > 1) begin
	localparam input_width = $clog2(output_width);
	wire [input_width - 1:0] inversed_select = ~select;
	for (genvar i = 0; i < output_width; ++i) begin: decoded_output
		wire [input_width - 1:0] selection;
		for (genvar j = 0; j < input_width; ++j) begin: selection_union
			assign selection[j] = i % (2 ** (j + 1)) >= 2 ** j ? select[j] : inversed_select[j];
		end
		assign out[i] = &selection;
	end
end else begin
	assign out = select;
end
endmodule
/*
Provides decoder.
Parameters:
	output_width - number of out bits (also defines width of select)
Ports:
	enable	- will set all outputs to 0
	select	- value to decode
	out		- decoded value
Notes:
	it supports non 2^n outputs, so it won`t overgenerate
*/
module _tree_decoder #(
	parameter output_width
) (
	input	wire										enable,
	input	wire [$clog2(`max(output_width, 2)) - 1:0]	select,
	output	wire [output_width - 1:0]					out
);
if (output_width > 1) begin
	localparam input_width = $clog2(output_width);
	wire [2 ** (input_width) - 2:0] mux_tree;
	assign mux_tree[0] = enable;
	for (genvar i = 1; i < input_width; ++i) begin: main_tree
		localparam size = 2 ** (i - 1);
		assign mux_tree[2 ** i - 1+:2 ** i] = {select[i - 1] ? mux_tree[2 ** i - 2-:size] : '0, select[i - 1] ? '0 : mux_tree[size - 1+:size]};
	end
	localparam size = 2 ** (input_width - 1);
	assign out = {select[input_width - 1] ? mux_tree[size - 1+:output_width - size] : '0, select[input_width - 1] ? '0 : mux_tree[size - 1+:size]};
end else begin
	assign out = select & enable;
end
endmodule
module decoder #(
	parameter output_width
) (
	
);
//is array/tree decoder
endmodule
/*
Legacy code, will be reorganised
*/
module decoder_c #(
	parameter output_width
) (
	input	wire enable,
	input	wire [$clog2(`max(output_width, 2)) - 1:0] select,
	output	wire [output_width - 1:0] out
);
wire [output_width - 1:0] raw_decoded;
_array_decoder #(.output_width(output_width)) dec (
	.select(select),
	.out(raw_decoded)
);
assign out = raw_decoded & {output_width{enable}};
endmodule
/*
Provides encoder.
Parameters:
	in_width - number of select bits (also defines width of out)
Ports:
	select	- value to encode
	out		- encoded value
Notes:
	it supports non 2^n inputs, so it won`t overgenerate
*/
module encoder #(
	parameter input_width
) (
	input wire [input_width - 1:0] select,
	output wire	[$clog2(`max(input_width, 2)) - 1:0] out
);
localparam output_width = $clog2(input_width);
genvar i;
genvar j;
if (input_width > 1) begin
	for (i = 0; i < output_width; ++i) begin: encoded_output
		localparam unit_size = 2 ** i;
		localparam rest_width = input_width % (2 * unit_size);
		localparam full_width = (input_width - rest_width) / 2;
		localparam collector_size = full_width + (rest_width > unit_size ? rest_width % unit_size : 0);
		wire [collector_size - 1:0] collector;
		for (j = 0; j < collector_size; j = j + unit_size) begin: selection_union
			localparam target_start = j * 2 + unit_size;
			assign collector[`min(collector_size, j + unit_size) - 1:j] = select[`min(input_width, target_start + unit_size) - 1:target_start];
		end
		if (collector_size > 1) begin
			assign out[i] = |collector;
		end else begin
			assign out[i] = collector;
		end
	end
end else begin
	assign out = select;
end
endmodule
/*
Legacy code, will be reorganised
*/
module tri_state_buffer #(
	parameter word_width,
	parameter word_length
) (
	input	wire [word_length - 1:0][word_width - 1:0] in,
	input	wire [word_length - 1:0] en,
	output	wire [word_width - 1:0] out
);
for (genvar i = 0; i < word_length; ++i) begin: buffer_unit
	assign out = en[i] ? in[i] : 'z;
end
endmodule