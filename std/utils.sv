`define STD_UTILS
`define min(a, b) ((a) > (b) ? (b) : (a))
`define max(a, b) ((a) > (b) ? (a) : (b))


//CARRY is a special case of DOUBLE_PRECISION
typedef enum bit[1:0] {LOGIC, ARITHMETIC, DOUBLE_PRECISION, CYCLIC} SHIFT_TYPE;
//NOTE: RCL is usually uses $size(C_IN) = 1
//WARNING: DO NOT SET $size(C_IN) >= $size(D_IN)!
`define RCL(D_IN, C_IN) {C_IN, D_IN[$size(D_IN) - 1:$size(C_IN)]}
//NOTE: RCR is usually uses $size(C_IN) = 1
//WARNING: DO NOT SET $size(C_IN) >= $size(D_IN)!
`define RCR(D_IN, C_IN) {D_IN[$size(D_IN) - 1:$size(C_IN)], C_IN}


//wire management
`include "utils/wires/bit_reverse.sv"
`include "utils/wires/screening_by_junior.sv"
`include "utils/wires/screening_by_senior.sv"
`include "utils/wires/encoder.sv"
`include "utils/wires/tree_decoder.sv"
//memory
`include "utils/memory/counter.sv"
`include "utils/memory/counter_forward.sv"
`include "utils/memory/counter_backward.sv"
//shifts
`include "utils/shifts/polyshift_l_cf.sv"
`include "utils/shifts/polyshift_l.sv"
`include "utils/shifts/polyshift_r_cf.sv"
`include "utils/shifts/polyshift_r.sv"
//adders
`include "utils/adders/RCA_M.sv"
`include "utils/adders/_LA.sv"
`include "utils/adders/_CSA_U.sv"
`include "utils/adders/CLAA.sv"
`include "utils/adders/CSA_S.sv"


`include "utils/fast_comparator.sv"


//TODO сумматор с условным переносом это 3 сумматора (младшие, 2 старших (Cin = 0 и 1))
//младший сумматор выбирает какой из старших подет в ответ
//то есть старшие это почти что CSA








/*
Provides decoder.
Parameters:
	output_width - number of out bits (also defines width of select)
Ports:
	select	- value to decode
	out		- decoded value
Notes:
	TODO: i
	it supports non 2^n outputs, so it won`t overgenerate
	it`s not reccomended to decode with large output_width (it will generate multiple large AND), use predecoding instead
*/
module _array_decoder #(
	parameter output_width
) (
	input	wire [$clog2(`max(output_width, 2)) - 1:0] select,
	output	wire [output_width - 1:0] out
);
genvar i;
genvar j;
generate
	if (output_width > 1) begin
		localparam input_width = $clog2(output_width);
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
