`define RF_ADDR_SIZE $clog2(stack_num * stack_size)
`define RF_STACK_ADDR(OPERAND, I) cell_SEL_``OPERAND[I][`RF_ADDR_SIZE - 1:`RF_ADDR_SIZE / 2]
`define RF_CELL_ADDR(OPERAND, I) cell_SEL_``OPERAND[I][`RF_ADDR_SIZE / 2 - 1:0]
module RF #(
	parameter cell_width = 8,
	parameter stack_size = 4,
	parameter stack_num = 4
) (
	input wire clk,
	input wire [cell_width - 1:0] cell_IN [stack_size - 1:0],
	input wire [`RF_ADDR_SIZE - 1:0] cell_SEL_A [stack_size - 1:0],
	input wire [`RF_ADDR_SIZE - 1:0] cell_SEL_B [stack_size - 1:0],
	input wire [`RF_ADDR_SIZE - 1:0] cell_SEL_C [stack_size - 1:0],
	input wire enable [stack_size - 1:0],
	output wire [cell_width - 1:0] cell_OUT_A [stack_size - 1:0],
	output wire [cell_width - 1:0] cell_OUT_B [stack_size - 1:0]
);
/*
заранее определяем модель: r = a <operation> b
т.к. векторная операция единственная в такт и другие операции не могут существовать в этот же такт это определяет:
	- что при векторной операции может быть взято 2 стека чтобы положить в 1 стек
	- что скалярная операция использует 2 ячейки (из 2ух стеков)
	- что суперскалярность не может превышать размер стека, потому что нельзя взять больше ячеек чем в стеке
значение stack_num * stack_size определяет число всех ячеек
значение stack_size * 2 определяет число ячеек, что будут доступны для чтения
значение stack_size также определяет число ячеек для записи
значение $clog2(stack_size) определяет адрес ячейки в стеке (см комментарии ниже об адресации)
значение $clog2(stack_num) определяет адрес стека (см комментарии ниже об адресации)

адресация ячейки это xy, где х это старшие биты (адрес стека), а у это младшие биты (адрес ячейки в стеке)
то есть для 8ми стеков из 8ми ячеек адрес будет в виде хххууу, где 3 старшие бита выбирают стек, а 3 младшие выбирают ячейку
особенность вектторной операции это набор адресов ячеек с одинаковым адресом стека, но с адресами от 0 до максимума для ячейки

Внимание!
для простоты нахождения длины адреса ячейки используется $clog2(stack_num * stack_size) вместо $clog2(stack_num) + $clog2(stack_size)
может быть изменено, поэтому define
*/
reg [cell_width - 1:0] registers [stack_size - 1:0][stack_num - 1:0];
genvar i;
generate
	for(i = 0; i < stack_size; i++) begin: OUT_A
		assign cell_OUT_A[i] = registers[`RF_STACK_ADDR(A, i)][`RF_CELL_ADDR(A, i)];
	end
	for(i = 0; i < stack_size; i++) begin: OUT_B
		assign cell_OUT_B[i] = registers[`RF_STACK_ADDR(B, i)][`RF_CELL_ADDR(B, i)];
	end
endgenerate
always @(posedge clk) begin
	for(integer i = 0; i < stack_size; i++) begin
		//	if (enable[i]) begin
			//В случае использовании модели a = a <operation> b используйте А, иначе C (не забудьте создать объект cell_SEL_C!)
			registers[`RF_STACK_ADDR(C, i)][`RF_CELL_ADDR(C, i)] <= cell_IN[i];
		//	end
	end
end
endmodule