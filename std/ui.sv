//переделать строку - младшие темные, старшие светлее (https://www.asciitable.com/)
`define STR_ALPHA "@QB#NgWM8RDHdOKq9$6khEPXwmeZaoS2yjufF]}{tx1zv7lciL/\\|?*>r^;:_\"~,'.-`" // яркость символов (плюс стоит учитывать, что байт позволяет использовать расширенную версию)
//NOTE: string is stored in reg[7:0] per character
`define DISPLAY(TYPE, WIDTH, MEM, SIZE) `_DISPLAY_``TYPE(WIDTH, MEM, SIZE)
`define CLEAR(SIZE)						\
	for(int _i = SIZE; _i; --_i) begin	\
		$display("\b \b");				\
	end




`define _DISPLAY_STR(WIDTH, MEM, SIZE)						\
	for (int _i = 0; _i < SIZE; _i += WIDTH) begin			\
		$display("%s", MEM[(_i + WIDTH) * 8 - 1:_i * 8]);	\
	end
//to do (should copy memory, not modify it)
`define _DISPLAY_A8(WIDTH, MEM, SIZE)				\
	for (int _i = 0; _i < SIZE; _i += WIDTH) begin	\
	string _s = MEM[(_i + WIDTH) * 8 - 1:_i * 8];	\
	for (int _j = 0; _j < WIDTH; ++_j) begin		\
		_s.putc(_j, `STR_ALPHA[_s.get(_j)]);		\
	end												\
	$display("%s", _s);								\
	end