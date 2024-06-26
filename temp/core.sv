module memory #(
	parameter word_width = 8
)(
	input	wire								clk,
	input	wire								write,
	inout	wire	[word_width - 1:0]			operand,
	input	wire	[$clog2(word_width) - 1:0]	operand_addr,
	output	wire	[word_width - 1:0]			PC_R,
	input	wire	[$clog2(word_width) - 1:0]	PC_ADRR
);
reg [$clog2(word_width) - 1: 0] mem;
assign operand = write ? 'z : mem[operand_addr];
assign PC_R = mem[PC_ADRR];
always @(posedge clk) begin
	if (write) begin
		mem[operand_addr] <= operand;
	end
end
endmodule
module core #(
	parameter word_width = 8
) (
	input	wire								clk,
	output	wire								write,
	input	wire	[word_width - 1:0]			operand,
	output	reg		[$clog2(word_width) - 1:0]	operand_addr,
	input	wire								reset,
	input	wire	[word_width - 1:0]			PC_R,
	output	reg		[$clog2(word_width) - 1:0]	PC_ADRR
);
reg [word_width - 1:0] A;
reg [1:0] state = '0;
reg [3:0] flags = '0;
/*
commands
fetch A
fetch operand_addr
push A
A <= A op RAM[operand_addr]

command structure
write [word_width - 1]| exec type [word_width - 2:word_width - 3] | args [word_width - 4:0]
args for fetch [1:0]
args for calc [2:0]
args for jump [1:0]


states
execute (00)
fetch A (01)
fetch operand_addr (10)
fetch operand (11)
*/
assign write = ~|state & PC_R[word_width - 1];
wire [word_width - 1:0][7:0] R = {
	A + operand,
	A - operand,
	~A,
	A & operand,
	A | operand,
	A ^ operand,
	A >> 1,
	A << 1
};
wire [7:0] EXPECTED_ZF = {
	(A + operand)	== 0,
	(A - operand)	== 0,
	(~A)	== 0,
	(A & operand)	== 0,
	(A | operand)	== 0,
	(A ^ operand)	== 0,
	(A >> 1)== 0,
	(A << 1)== 0
};
wire [7:0] EXPECTED_CF = {
	(A + operand)	> 2 ** word_width - 1,
	(A - operand)	< 0,
	1'b0,
	1'b0,
	1'b0,
	1'b0,
	1'b0,
	1'b0
};
wire [word_width - 1:0] A_p = A + operand;
wire [word_width - 1:0] A_m = A - operand;
wire [7:0] EXPECTED_OF = {
	A[word_width - 1] ^ A_p[word_width - 1],
	A[word_width - 1] ^ A_m[word_width - 1],
	1'b0,
	1'b0,
	1'b0,
	1'b0,
	1'b0,
	1'b0
};
always @(posedge clk) begin
	if (reset) begin
		//RESET
		state <= '0;
		PC_ADRR <= '0;
	end else begin
		//FETCH SPECIFIC
		if (state == 2'b01) begin	//RAM[PC]->A
			A <= PC_R;
		end else if (state == 2'b10) begin	//RAM[PC]->operand_addr
			operand_addr <= PC_R[$clog2(word_width) - 1:0];
		end else if (state == 2'b11) begin	//RAM[operand_addr]->A
			A <= operand;
		end
		if (|state) begin
			state <= '0;
			PC_ADRR <= PC_ADRR + 1;
		end else begin
			//EXECUTE SPECIFIC
			if (PC_R[word_width - 2:word_width - 3] == 0) begin	//fetch
				state <= PC_R[1:0];
				PC_ADRR <= PC_ADRR + 1;
			end else if (PC_R[word_width - 2:word_width - 3] == 1) begin //calc
				A <= R[PC_R[2:0]];
				flags <= {EXPECTED_CF[PC_R[1:0]], EXPECTED_OF[PC_R[1:0]], EXPECTED_ZF[PC_R[1:0]], 1'b1};
				PC_ADRR <= PC_ADRR + 1;
			end else if (flags[PC_R[1:0]]) begin	//jump
				PC_ADRR <= A;
			end
		end
	end
end
endmodule