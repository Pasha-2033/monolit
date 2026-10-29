/*
Provides:
	General-Purpose Timer (GPT)
Dependencies:
	_prescaler
	tree_decoder
	counter_forward
Parameters:
	CNTR_WORD_WIDTH	- width of input and output words (for reset value)
	PS_WORD_WIDTH	- width of input and output words (prescaler)
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	ae_i			- action enable
	action_i		- action
	value_i			- value for comparison and prescaler
	target_irq_o	- target value compared
	overflow_irq_o	- counter overflow happened
	cntr_value_o	- counter value
Generation:
	None
Additional comments:
	Has only 1 word for comparison, that's why it's MONO
Action table:
	action_i = 0	- set prescaler delay
	action_i = 1	- set comparison value
	action_i = 2	- handle comparement
	action_i = 3	- handle overflow
*/
module MONO_GPT #(
	parameter PS_WORD_WIDTH,
	parameter CNTR_WORD_WIDTH
) (
	input	wire													clk_i,
	input	wire													arst_i,

	input	wire	[`max(PS_WORD_WIDTH, CNTR_WORD_WIDTH) - 1:0]	value_i,

	input	wire													ae_i, //action enable
	input	wire	[1:0]											action_i,

	output	reg														target_irq_o,
	output	reg														overflow_irq_o,

	output	wire	[CNTR_WORD_WIDTH - 1:0]							cntr_value_o
);
//actions:
//set prsclr
//set cmp_word
//handle comparement
//handle overflow
reg is_set;
reg [CNTR_WORD_WIDTH - 1:0] cmp_word;
wire set_prsclr;
wire set_cmp_word;
wire handle_comparement;
wire handle_overflow;
wire overflow;
wire cntr_clock_en;
tree_decoder #(.OUTPUT_WIDTH(4)) action_decoder (
	.enable_i(ae_i),
	.select_i(action_i),
	.data_o({handle_overflow, handle_comparement, set_cmp_word, set_prsclr})
);
_prescaler #(.WORD_WIDTH(PS_WORD_WIDTH)) prsclr (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.we_i(set_prsclr),
	.clk_value_i(value_i[PS_WORD_WIDTH - 1:0]),
	.clk_en_o(cntr_clock_en)
);
counter_forward #(.WORD_WIDTH(CNTR_WORD_WIDTH), .WORD_RESET(0)) cntr (
	.clk_i(clk_i),
	.action_i(~cntr_clock_en),
	.arst_i(arst_i),
	.data_i(cntr_value_o),
	.data_o(cntr_value_o),
	.will_overflow_o(overflow)
);
always_ff @(posedge arst_i or posedge clk_i) begin
	if (arst_i) begin
		target_irq_o <= '0;
		overflow_irq_o <= '0;
		cmp_word <= '0;
		is_set <= '0;
	end else begin
		if (set_cmp_word) begin
			cmp_word <= value_i[CNTR_WORD_WIDTH - 1:0];
			is_set <= '1;
		end
		if (handle_comparement) begin
			target_irq_o <= '0;
			is_set <= '0;
		end else if (is_set) begin
			target_irq_o <= target_irq_o | ~|(cmp_word ^ cntr_value_o);
		end
		if (handle_overflow) begin
			overflow_irq_o <= '0;
		end else begin
			overflow_irq_o <= overflow_irq_o | overflow;
		end
	end
end
endmodule
/*
Provides:
	General-Purpose Timer (GPT)
Dependencies:
	_prescaler
	tree_decoder
	counter_forward
	screening_by_junior
	screening_by_senior
	RCA_M
Parameters:
	CNTR_WORD_WIDTH	- width of input and output words (for reset value)
	PS_WORD_WIDTH	- width of input and output words (prescaler)
Ports:
	clk_i			- clock
	arst_i			- asynchronous reset
	ae_i			- action enable
	action_i		- action
	value_i			- value for comparison and prescaler
	target_irq_o	- target value compared
	overflow_irq_o	- counter overflow happened
	cntr_value_o	- counter value
Generation:
	None
Additional comments:
	Has only 1+ word for comparison, that's why it's MONO
Action table:
	action_i = 0	- set prescaler delay
	action_i = 1	- set comparison value
	action_i = 2	- handle comparement
	action_i = 3	- handle overflow
*/
module POLY_GPT #(
	parameter PS_WORD_WIDTH,
	parameter CNTR_WORD_WIDTH,
	parameter DESC_WORD_WIDTH,
	parameter CMP_NUM
) (
	input	wire																	clk_i,
	input	wire																	arst_i,

	input	wire	[`max(PS_WORD_WIDTH, CNTR_WORD_WIDTH + DESC_WORD_WIDTH) - 1:0]	value_i,

	input	wire																	ae_i, //action enable
	input	wire	[1:0]															action_i,

	
	output	wire	[CNTR_WORD_WIDTH - 1:0]											cntr_value_o,

	output	wire	[DESC_WORD_WIDTH - 1:0]											dsc_word_o,

	output	wire																	target_irq_o,
	output	reg																		overflow_irq_o,
	output	wire																	all_cmp_busy_o
);
//actions:
//set prsclr
//set cmp_word
//handle comparement
//handle overflow
reg [CMP_NUM - 1:0] is_irq;
reg [CMP_NUM - 1:0] is_set;
reg [CMP_NUM - 1:0][CNTR_WORD_WIDTH - 1:0] cmp_word;
reg [CMP_NUM - 1:0][DESC_WORD_WIDTH - 1:0] dsc_word;
wire [CNTR_WORD_WIDTH - 1:0] final_cmp_word;
wire [CMP_NUM - 1:0] set_control;
wire [CMP_NUM - 1:0] handle_control;
wire set_prsclr;
wire set_cmp_word;
wire handle_comparement;
wire handle_overflow;
wire overflow;
wire cntr_clock_en;
assign all_cmp_busy_o = &is_set;
assign target_irq_o = |is_irq;
screening_by_junior #(.WORD_WIDTH(CMP_NUM)) cmp_set_controller (
	.c_i('0),
	.data_i(~is_set),
	.data_o(set_control)
);
screening_by_senior #(.WORD_WIDTH(CMP_NUM)) cmp_handle_controller (
	.c_i('0),
	.data_i(is_set),
	.data_o(handle_control)
);
RCA_M #(.WORD_WIDTH(CNTR_WORD_WIDTH)) adder (
	.c_i('1),
	.a_i(cntr_value_o),
	.b_i(value_i[CNTR_WORD_WIDTH - 1:0]),
	.r_o(final_cmp_word)
);
tree_decoder #(.OUTPUT_WIDTH(4)) action_decoder (
	.enable_i(ae_i),
	.select_i(action_i),
	.data_o({handle_overflow, handle_comparement, set_cmp_word, set_prsclr})
);
_prescaler #(.WORD_WIDTH(PS_WORD_WIDTH)) prsclr (
	.clk_i(clk_i),
	.arst_i(arst_i),
	.we_i(set_prsclr),
	.clk_value_i(value_i[PS_WORD_WIDTH - 1:0]),
	.clk_en_o(cntr_clock_en)
);
counter_forward #(.WORD_WIDTH(CNTR_WORD_WIDTH), .WORD_RESET(0)) cntr (
	.clk_i(clk_i),
	.action_i(~cntr_clock_en),
	.arst_i(arst_i),
	.data_i(cntr_value_o),
	.data_o(cntr_value_o),
	.will_overflow_o(overflow)
);
genvar i;
generate
	if (CMP_NUM > 1) begin
		wire [CMP_NUM - 1:0][DESC_WORD_WIDTH - 1:0] dsc_output;
		assign dsc_output[0] = dsc_word[0];
		assign dsc_word_o = dsc_output[CMP_NUM - 1];
		for (i = 0; i < CMP_NUM - 1; ++i) begin : desc_cascade
			assign dsc_output[i + 1] = is_irq[i + 1] ? dsc_word[i + 1] : dsc_output[i];
		end
	end else begin
		assign dsc_word_o = dsc_word;
	end
endgenerate
always_ff @(posedge arst_i or posedge clk_i) begin
	if (arst_i) begin
		is_irq <= '0;
		is_set <= '0;
		cmp_word <= '0;
		dsc_word <= '0;
		overflow_irq_o <= '0;
	end else begin
		if (handle_overflow) begin
			overflow_irq_o <= overflow;
		end else begin
			overflow_irq_o <= overflow_irq_o | overflow;
		end
		if (set_cmp_word & ~all_cmp_busy_o) begin
			for (int i = 0; i < CMP_NUM; ++i) begin
				if (set_control[i]) begin
					is_set[i] <= '1;
					cmp_word[i] <= final_cmp_word;
					dsc_word[i] <= value_i[CNTR_WORD_WIDTH+:DESC_WORD_WIDTH];
				end
			end
		end else begin
			for (int i = 0; i < CMP_NUM; ++i) begin
				if (handle_control[i] & handle_comparement) begin
					is_set[i] <= '0;
					is_irq[i] <= '0;
				end else if (is_set[i]) begin
					is_irq[i] <= is_irq[i] | ~|(cmp_word[i] ^ cntr_value_o);
				end
			end
		end
	end
end
endmodule