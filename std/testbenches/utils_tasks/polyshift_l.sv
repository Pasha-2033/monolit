module task_polyshift_l #(
	parameter WORD_WIDTH
);
logic [WORD_WIDTH - 2:0] C_IN;
logic [WORD_WIDTH - 1:0] D_IN;
SHIFT_TYPE _type;
logic [$clog2(WORD_WIDTH) - 1:0] _size;
wire [WORD_WIDTH - 1:0] D_OUT;
polyshift_l #(.WORD_WIDTH(WORD_WIDTH)) psr (
	.data_i(D_IN),
	.c_i(C_IN),
	.shift_size_i(_size[2:0]),
	.shift_type_i(_type),
	.data_o(D_OUT)
);
//check values
wire [WORD_WIDTH * 2 - 1:0] rol = {D_IN, D_IN};
wire [WORD_WIDTH * 2 - 1:0] rcl = {D_IN, C_IN, 1'b0};
wire [WORD_WIDTH * 2 - 1:0] post_rol = rol << _size;
wire [WORD_WIDTH * 2 - 1:0] post_rcl = rcl << _size;
wire [3:0][WORD_WIDTH - 1:0] expected_value = {
	post_rol[WORD_WIDTH+:WORD_WIDTH],
	post_rcl[WORD_WIDTH+:WORD_WIDTH],
	$signed(D_IN) <<< _size,
	D_IN << _size
};
task run(input [WORD_WIDTH - 1:0] value, input [WORD_WIDTH - 2:0] double_precision);
	begin
		D_IN = value;
		C_IN = double_precision;
		_type = LOGIC;
		repeat (_type.num()) begin
			_size = 0;
			repeat (WORD_WIDTH) begin
				#10
				$display("%s\tEXPECTED: %b\tGOT: %b\tD: %b\tC: %b\tSHIFT: %d\tTYPE: %s", D_OUT == expected_value[_type] ? "OK  " : "FAIL", expected_value[_type], D_OUT, D_IN, C_IN, _size, _type.name());
				++_size;
			end
			++_type;
		end
	end
endtask
endmodule