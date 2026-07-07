`define STD_UTILS 1
`define min(a, b) ((a) > (b) ? (b) : (a))
`define max(a, b) ((a) > (b) ? (a) : (b))

`define IS_2POW(N) (|N & ~|(N & N - 1))
`define POW2_DIFF(N) (2 ** $clog2(N) - N)

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
`include "utils/wires/signed_extension.sv"
`include "utils/wires/screening_by_junior.sv"
`include "utils/wires/screening_by_senior.sv"
`include "utils/wires/encoder.sv"
`include "utils/wires/tree_decoder.sv"
//memory
`include "utils/memory/counter.sv"
`include "utils/memory/counter_forward.sv"
`include "utils/memory/counter_backward.sv"
`include "utils/memory/stack.sv"
`include "utils/memory/queue.sv"
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
//atomic
`include "utils/atomic/one_bit_sync.sv"
`include "utils/atomic/cdc_handshake.sv"

//unsorted
`include "utils/fast_comparator.sv"
`include "utils/clk_reductor.sv"


//TODO сумматор с условным переносом это 3 сумматора (младшие, 2 старших (Cin = 0 и 1))
//младший сумматор выбирает какой из старших подет в ответ
//то есть старшие это почти что CSA

