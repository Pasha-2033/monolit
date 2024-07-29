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
)(
	input	wire [word_width - 1:0] in,
	output	wire [word_width - 1:0] out
);
genvar i;
generate
	for(i = 0; i < word_width; ++i) begin: reverse
		assign out[i] = in[word_width - i - 1];
	end
endgenerate
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
	P		- propagation
	G		- generation
	C_OUT	- cary output
Generation:
	fast_adder is recusrsive module
	if word_width > cascade_size then lookahead and lower level is generated
	else ripple-carry adder is generated
	lower level is smaller fast adders
*/
module fast_adder #(
	parameter cascade_size = 4,
	parameter word_width = 4
) (
	input	wire					C_IN,
	input	wire [word_width - 1:0]	A,
	input	wire [word_width - 1:0]	B,
	output	wire [word_width - 1:0]	R,
	output	wire					P,
	output	wire					G,
	output	wire					C_OUT
);
localparam cascade_num = word_width / cascade_size;
wire [cascade_size - 1:0] PP;
wire [cascade_size - 1:0] PG;
wire [cascade_size - 1:0] GG;
wire [cascade_size:0] C;
assign C[0] = C_IN;
assign C_OUT = C[cascade_size];
assign P = &PP;
assign G = |GG;
genvar i;
genvar j;
generate
	if (cascade_num > 1) begin
		//creating lowest level
		for(i = 0; i < cascade_size; ++i) begin: adder_cascade
			fast_adder #(.cascade_size(cascade_size), .word_width(cascade_num)) child_fast_adder (
				.C_IN(C[i]),
				.A(A[i * cascade_num+:cascade_num]),
				.B(B[i * cascade_num+:cascade_num]),
				.R(R[i * cascade_num+:cascade_num]),
				.P(PP[i]),
				.G(PG[i])
			);
		end
	end else begin
		//lowest level implementation
		for(i = 0; i < cascade_size; ++i) begin: bit_cascade
			//can be optimised by component num (TODO?)
			assign R[i] = A[i] ^ B[i] ^ C[i];
			assign PP[i] = A[i] | B[i];
			assign PG[i] = A[i] & B[i];
		end
	end
	//lookahead implementation
	for(i = 0; i < cascade_size; ++i) begin: signal_cascade
		if (i == cascade_size - 1) begin
			assign GG[i] = PG[i];
		end else begin
			assign GG[i] = PG[i] & (&PP[cascade_size - 1:i + 1]);
		end
		wire [i + 1:0] PRE_C;
		assign PRE_C[i + 1] = PG[i];
		assign PRE_C[0] = C_IN & (&PP[i:0]);
		for (j = 0; j < i; ++j) begin: c_cascade
			assign PRE_C[j + 1] = PG[j] & (&PP[i:j + 1]);
		end
		assign C[i + 1] = |PRE_C;
	end
endgenerate
endmodule
//CARRY is a special case of DOUBLE_PRECISION
typedef enum bit[1:0] {LOGIC, ARITHMETIC, DOUBLE_PRECISION, CYCLIC} SHIFT_TYPE;
//WARNING: DO NOT SET $size(C_IN) != 1
`define RCR(D_IN, C_IN) {D_IN[$size(D_IN) - 2:1], C_IN}
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
genvar i;
generate
	for(i = 1; i < word_width; ++i) begin: input_generation
		assign shift_input[i] = {shift_arg[i - 1:0], D_IN[word_width - 1:i]};
	end
endgenerate
endmodule
//WARNING: DO NOT SET $size(D_IN) != word_width parameter in polyshift_l
`define RCL(D_IN, C_IN) {C_IN, D_IN[$size(D_IN) - 2:1]}
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
genvar i;
generate
	for(i = 1; i < word_width; ++i) begin: input_generation
		assign shift_input[i] = {D_IN[word_width - i - 1:0], shift_arg[word_width - 2:word_width - i - 1]};
	end
endgenerate
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
module counter_c #(
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
module counter_cs_forward #(
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
module counter_cs_backward #(
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
module decoder #(
	parameter output_width
) (
	input	wire [`max($clog2(output_width), 1) - 1:0] select,
	output	wire [output_width - 1:0] out
);
localparam input_width = $clog2(output_width);
genvar i;
genvar j;
generate
	if (output_width > 1) begin
		wire [input_width - 1:0] inversed_select = ~select;
		for (i = 0; i < output_width; ++i) begin: decoded_output
			wire [input_width - 1:0] selection;
			for (j = 0; j < input_width; ++j) begin: selection_union
				assign selection[j] = i % (2 ** (j + 1)) >= 2 ** j ? select[j] : inversed_select[j];
			end
			assign out[i] = &selection;
		end
	end else begin
		assign out = select;
	end
endgenerate
endmodule
/*
Legacy code, will be reorganised
*/
module decoder_c #(
	parameter output_width
) (
	input	wire enable,
	input	wire [`max($clog2(output_width), 1) - 1:0] select,
	output	wire [output_width - 1:0] out
);
wire [output_width - 1:0] raw_decoded;
decoder #(.output_width(output_width)) dec (
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
Warnings:
	DO NOT SET input_width = 1
Notes:
	it supports non 2^n inputs, so it won`t overgenerate
*/
module encoder #(
	parameter input_width
) (
	input wire [input_width - 1:0] select,
	output wire	[`max($clog2(input_width), 1) - 1:0] out
);
localparam output_width = $clog2(input_width);
genvar i;
genvar j;
generate
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
endgenerate
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
genvar i;
generate
	for (i = 0; i < word_length; ++i) begin: buffer_unit
		assign out = en[i] ? in[i] : 'z;
	end
endgenerate
endmodule