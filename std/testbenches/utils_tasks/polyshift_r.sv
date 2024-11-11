module task_polyshift_r #(
	parameter word_width
);
logic [word_width - 2:0] C_IN;
logic [word_width - 1:0] D_IN;
SHIFT_TYPE _type;
logic [$clog2(word_width) - 1:0] _size;
wire [word_width - 1:0] D_OUT;
polyshift_r #(.word_width(word_width)) psr (
	.D_IN(D_IN),
	.C_IN(C_IN),
	.shift_size(_size[2:0]),
	.shift_type(_type),
	.D_OUT(D_OUT)
);
//check values
wire [word_width * 2 - 1:0] ror = {D_IN, D_IN};
wire [word_width * 2 - 2:0] rcr = {C_IN, D_IN};
wire [word_width - 1:0] post_ror = ror >> _size;
wire [word_width - 1:0] post_rcr = rcr >> _size;
wire [3:0][word_width - 1:0] expected_value = {
	post_ror,
	post_rcr,
	$signed(D_IN) >>> _size,
	D_IN >> _size
};
task run(input [word_width - 1:0] value, input [word_width - 2:0] double_precision);
	begin
		D_IN = value;
		C_IN = double_precision;
		_type = LOGIC;
		repeat (_type.num()) begin
			_size = 0;
			repeat (word_width) begin
				#10
				$display("%s\tEXPECTED: %b\tGOT: %b\tD: %b\tC: %b\tSHIFT: %d\tTYPE: %s", D_OUT == expected_value[_type] ? "OK  " : "FAIL", expected_value[_type], D_OUT, D_IN, C_IN, _size, _type.name());
				++_size;
			end
			++_type;
		end
	end
endtask
endmodule