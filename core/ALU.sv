/*
ЦПУ АЛУ 1.0
ДОКУМЕНТАЦИЯ
Данный АЛУ использует 4 функциональных блока
- арифметический (+/-/+CF/-CF)
- логический (~,&,|,^)
- сдвиг влево (логический, сдвиг с добавлением 1, логический (можно апгрейднуть в будущем), циклический)
- сдвиг влево (логический, сдвиг с добавлением 1, арифметический, циклический)



*/
enum {
	ARITHMETIC,
	LOGIC,
	LSHIFT,
	RSHIFT
} ALU_SUBMODULE;
module ALU #(
	parameter bit_width = 4
)(
	input wire	[1:0]				IN_OP	[RSHIFT:ARITHMETIC],
	input wire	[bit_width - 1:0]	IN_A    [RSHIFT:ARITHMETIC],
	input wire	[bit_width - 1:0]	IN_B    [RSHIFT:ARITHMETIC],
	output wire	[bit_width - 1:0]	OUT_R   [RSHIFT:ARITHMETIC],
	//temp solution
	input wire CF_IN,
	output wire CF, OF, ZF
);
genvar i;
//ARITHMETIC BLOCK
/*TODO:
 - сделать ускоренный перенос, скорее всего сумматор станет модулем
 - изменить ZF с == 0 на более экномичный модуль по проверке на 1 на любой из входов путем ИЛИ
*/
wire [bit_width - 1:0] ADDER;
assign {CF, ADDER} = (IN_OP[ARITHMETIC][0] ? ~IN_A[ARITHMETIC] : IN_A[ARITHMETIC]) + IN_B[ARITHMETIC] + (CF_IN & IN_OP[ARITHMETIC][1]);
assign OF = OUT_R[ARITHMETIC][bit_width - 1] ^ IN_A[ARITHMETIC][bit_width - 1];
assign ZF = (OUT_R[ARITHMETIC] == 0);
assign OUT_R[ARITHMETIC] = IN_OP[ARITHMETIC][0] ? ~ADDER : ADDER;
//LOGIC BLOCK
wire [bit_width - 1:0] AND = IN_A[LOGIC] & IN_B[LOGIC];
wire [bit_width - 1:0] OR = IN_A[LOGIC] | IN_B[LOGIC];
wire [bit_width - 1:0] XOR = OR & ~AND;
wire [bit_width - 1:0][3:0] LOGIC_BLOCK = {XOR, OR, AND, ~IN_A[LOGIC]};
assign OUT_R[LOGIC] = LOGIC_BLOCK[IN_OP[LOGIC]];
//LSHIFT
wire [bit_width - 2:0][3:0] LSHIFT_TYPES = {IN_A[LSHIFT][bit_width - 2:0], '0, '1, '0};
wire [bit_width - 2:0] LSHIFT_TYPE_DEFINER = LSHIFT_TYPES[IN_OP[LSHIFT]];
wire [bit_width - 1:0][bit_width - 1:0] LSHIFT_INPUT;
generate
	for (i = 0; i < bit_width; i++) begin: LSHIFT_input_generation
		assign LSHIFT_INPUT[i][bit_width - i - 1:0] = IN_A[LSHIFT][bit_width - 1:i];
		if (i > 0) begin
			assign LSHIFT_INPUT[i][bit_width - 1:bit_width - i] = LSHIFT_TYPE_DEFINER[i - 1:0];
		end
	end
	for (i = 0; i < bit_width; i++) begin: LSHIFT_output_generation
		assign OUT_R[LSHIFT][i] = LSHIFT_INPUT[i][IN_B[LSHIFT][$clog2(bit_width) - 1:0]];
	end
endgenerate
//RSHIFT
wire [bit_width - 2:0][3:0] RSHIFT_TYPES = {IN_A[RSHIFT][bit_width - 2:0], {(bit_width - 2){IN_A[RSHIFT][bit_width - 1]}}, '1, '0};
wire [bit_width - 2:0] RSHIFT_TYPE_DEFINER = RSHIFT_TYPES[IN_OP[RSHIFT]];
wire [bit_width - 1:0][bit_width - 1:0] RSHIFT_INPUT;
generate
	for (i = 0; i < bit_width; i++) begin: RSHIFT_input_generation
		bit_reverse #(i + 1) reverse_in_a (IN_A[RSHIFT][i:0], RSHIFT_INPUT[i][i:0]);
		if (i < bit_width - 1) begin
			bit_reverse #(bit_width - i - 1) reverse_definer (RSHIFT_TYPE_DEFINER[bit_width - 2:i], RSHIFT_INPUT[i][bit_width - 1:i + 1]);
		end
	end
	for (i = 0; i < bit_width; i++) begin: RSHIFT_output_generation
		assign OUT_R[RSHIFT][i] = RSHIFT_INPUT[i][IN_B[RSHIFT][$clog2(bit_width) - 1:0]];
	end
endgenerate
endmodule