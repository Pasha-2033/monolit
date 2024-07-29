`ifndef STD_UTILS
	`include "utils.sv"
`endif
`define STD_IO
typedef enum bit {R_HIGH_SCL, R_LOW_SCL} IIC_R_STATE;
typedef enum bit {W_HIGH_SCL, W_LOW_SCL} IIC_W_STATE;
//doesn`t support 4+ versions of IIC
module _IIC_handler #(
	parameter word_width = 8
)(
	input	wire						clk,	
	input	wire						NRCS,	//~(read completed successful)
	input	wire						WE,
	input	wire	[word_width - 1:0]	D_IN,
	output	reg		[word_width - 1:0]	D_OUT,
	output	wire						signal,
	//IIC interface
	input	wire						SDA_IN,
	input	wire						SCL_IN,
	output	wire						SDA_OUT,
	output	reg							SCL_OUT
);
reg read_state;
reg write_state;
reg R_SDA;
reg W_SDA;
assign SDA_OUT = R_SDA & W_SDA;
assign signal = SCL_IN & (D_OUT[0] ^ SDA_IN);
always_ff @(posedge clk) begin
	case(read_state)
		R_HIGH_SCL: begin
			if (SCL_IN) begin
				D_OUT <= {D_OUT[word_width - 2:0], SDA_IN};
				read_state <= R_LOW_SCL;
			end
		end
		R_LOW_SCL: begin
			if (~SCL_IN) begin
				R_SDA <= NRCS;	//ACK
				read_state <= R_HIGH_SCL;
			end
		end
	endcase
	case (write_state)
		W_HIGH_SCL: begin
			if (SCL_IN & WE/*TODO*/) begin
				write_state <= W_LOW_SCL;
				SCL_OUT <= '0;
			end
		end
		W_LOW_SCL: begin
			//set data bit/ACK/NACK
			write_state <= W_HIGH_SCL;
			SCL_OUT <= '1;
		end
	endcase
end
endmodule

















/*
Warnings:
	DO NOT SET SS_width = 1
*/
module SPI #(
	parameter word_width = 8,
	parameter SS_width = 1
) (
	input	wire										clk,
	input	wire										SE,			//sync edge 0 - high, 1 - low (CPOL ^ CPHA)
	input	wire										WE,			
	input	wire										SSE,		//slave seletion enable (can be set to 1 ONLY BY MASTER!!!)
	input	wire	[`max($clog2(SS_width), 1) - 1:0]	SSV,		//slave selection value
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