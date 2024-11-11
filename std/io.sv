`ifndef STD_UTILS
	`include "utils.sv"
`endif
`define STD_IO
typedef enum bit {W_HIGH_SCL, W_LOW_SCL} IIC_HW_STATE;
//doesn`t support 4+ versions of IIC
module _IIC_HANDLER #(
	parameter word_width = 8
)(
	input	wire						clk,
	input	wire						NRCS,	//~(read completed successful)
	input	wire						WE,
	input	wire						D_IN,	//bit of DATA IN
	output	reg		[word_width - 1:0]	D_OUT,
	output	wire						signal,	//signals that START/RSTART/STOP happened
	output	reg							write_state,
	//IIC interface
	input	wire						SDA_IN,
	input	wire						SCL_IN,
	output	wire						SDA_OUT,
	output	reg							SCL_OUT
);
reg R_SDA;
assign SDA_OUT = R_SDA & (D_IN | ~WE); //set DATA/ACK/NACK by read/write
assign signal = SCL_IN & (D_OUT[0] ^ SDA_IN);
always_ff @(posedge SCL_IN) begin
	D_OUT <= {D_OUT[word_width - 2:0], SDA_IN};
end
always_ff @(negedge SCL_IN) begin
	R_SDA <= NRCS;	//ACK by read
end
always_ff @(posedge clk) begin
	case (write_state)
		W_HIGH_SCL: begin
			if (SCL_IN & WE) begin
				write_state <= W_LOW_SCL;
				SCL_OUT <= '0;
			end
		end
		W_LOW_SCL: begin
			write_state <= W_HIGH_SCL;
			SCL_OUT <= '1; 
		end
	endcase
end
endmodule
//typedef enum bit {  } IIC_R_STATE;
//typedef enum bit {  } IIC_W_STATE;
module IIC #(
	parameter word_width = 8
) (
	input	wire						clk,
	input	wire						address,


	//IIC interface
	input	wire						SDA_IN,
	input	wire						SCL_IN,
	output	wire						SDA_OUT,
	output	wire						SCL_OUT
);
wire signal;
counter_backward #(.word_width(word_width)/*TODO*/) reader_counter (
	.clk(~SCL_IN/*TODO*/)
);
counter_backward #(.word_width(word_width)/*TODO*/) writer_counter (
	.clk(~SCL_IN/*TODO*/)
);
_IIC_HANDLER #(.word_width(word_width)) line_handler (
	.clk(clk),


	.signal(signal),


	.SDA_IN(SDA_IN),
	.SCL_IN(SCL_IN),
	.SDA_OUT(SDA_OUT),
	.SCL_OUT(SCL_OUT)
);
always_ff @(posedge clk) begin
	
end
endmodule
/*
*/
module SPI #(
	parameter word_width = 8,
	parameter SS_width = 1
) (
	input	wire										clk,
	input	wire										SE,			//sync edge 0 - high, 1 - low (CPOL ^ CPHA)
	input	wire										WE,			
	input	wire										SSE,		//slave seletion enable (can be set to 1 ONLY BY MASTER!!!)
	input	wire	[$clog2(`max(SS_width, 2)) - 1:0]	SSV,		//slave selection value
	input	wire	[word_width - 1:0]					D_IN,
	output	reg		[word_width - 1:0]					D_OUT,
	//SPI interface
	input	wire										SS_IN,		//slave selection (if master - always 1)
	input	wire										SCLK,		//master and slave will use same SCLK for shift registers (but only master can clock - clk & en)
	input	wire										SD_IN,		//MOSI - if slave else - MISO
	output	wire										SD_OUT,		//MISO - if slave else - MOSI
	output	wire	[SS_width - 1:0]					SS_OUT		//slave selection
);
decoder_c #(.output_width(SS_width)) SS_decoder (
	.enable(SSE),
	.select(SSV),
	.out(SS_OUT)
);
assign SD_OUT = D_OUT[word_width - 1];
wire SPI_clk = SS_IN ? clk : SE ^ SCLK;
always_ff @(posedge SPI_clk) begin
	if (SS_IN & ~SSE) begin
		if (WE) begin
			D_OUT <= D_IN;
		end
	end else begin
		D_OUT <= {D_OUT[word_width - 2:0], SD_IN};
	end
end
endmodule