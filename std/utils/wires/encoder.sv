/*
Provides:
	Encoder
Dependencies:
	NONE
Parameters:
	INPUT_WIDTH - number of select bits (also defines width of out)
Ports:
	select_i	- value to encode
	data_o		- encoded value
Generation:
	Creates collectors and assings them to uotput
Additional comments:
	Fully combinational
	Supports non 2^n inputs, so it won`t overgenerate
*/
module encoder #(
	parameter INPUT_WIDTH
) (
	input	wire	[INPUT_WIDTH - 1:0]						select_i,
	output	wire	[$clog2(`max(INPUT_WIDTH, 2)) - 1:0]	data_o
);
localparam OUTPUT_WIDTH = $clog2(INPUT_WIDTH);
genvar i;
genvar j;
generate
	if (INPUT_WIDTH > 1) begin
		for (i = 0; i < OUTPUT_WIDTH; ++i) begin: encoded_output
			localparam UNIT_SIZE		= 2 ** i;
			localparam REST_WIDTH		= INPUT_WIDTH % (2 * UNIT_SIZE);
			localparam FULL_WIDTH		= (INPUT_WIDTH - REST_WIDTH) / 2;
			localparam COLLECTOR_SIZE	= FULL_WIDTH + (REST_WIDTH > UNIT_SIZE ? REST_WIDTH % UNIT_SIZE : 0);

			wire [COLLECTOR_SIZE - 1:0] collector;
			for (j = 0; j < COLLECTOR_SIZE; j = j + UNIT_SIZE) begin: selection_union
				localparam TARGET_START = j * 2 + UNIT_SIZE;
				assign collector[`min(COLLECTOR_SIZE, j + UNIT_SIZE) - 1:j] = select_i[`min(INPUT_WIDTH, TARGET_START + UNIT_SIZE) - 1:TARGET_START];
			end

			if (COLLECTOR_SIZE > 1) begin
				assign data_o[i] = |collector;
			end
			else begin
				assign data_o[i] = collector;
			end
		end
	end
	else begin
		assign data_o = select_i;
	end
endgenerate
endmodule