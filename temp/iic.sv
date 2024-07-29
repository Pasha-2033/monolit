module IIC #(
	parameter word_width = 8
) (
	input wire clk,
	input wire SCL_IN,
	input wire SDA_IN,
	output reg SCL_OUT,
	output reg SDA_OUT,
	input wire WE,
	input wire [word_width - 1:0] D_IN,
	output reg [word_width - 1:0] D_OUT,
	output reg OUT_READY,
	output wire IN_READY
);
assign IN_READY = (write_state == AWAITING_WORD);
reg [$clog2(word_width):0] W_COUNTER;
reg SDA_IN_REG;
reg [word_width - 1:0] D_IN_REG;
wire in_occupied = |W_COUNTER;
enum reg [1:0] {LISTEN_START, LISTEN_BIT, AWAITING_BIT} read_state = LISTEN_START;
enum reg [1:0] {AWAITING_WORD, SENDING_START, LOW_SCL, HIGH_SCL} write_state = LISTEN_START;
always @(posedge clk) begin
	case (read_state)
		LISTEN_START: begin
			if (~(SDA_IN | SCL_IN)) begin
				read_state <= AWAITING_BIT;
			end
		end
		LISTEN_BIT: begin
			if (SCL_IN) begin
				if (SDA_IN_REG ^ SDA_IN) begin
					read_state <= LISTEN_START;
					OUT_READY = '1;
				end
			end else begin
				D_OUT <= {D_OUT[word_width - 2:0], SDA_IN_REG};
				read_state <= AWAITING_BIT;
				OUT_READY = '0;
			end
		end
		AWAITING_BIT: begin
			if (SCL_IN) begin
				SDA_IN_REG <= SDA_IN;
				read_state <= LISTEN_BIT;
			end
		end
	endcase
	case (write_state)
		AWAITING_WORD: begin
			if (WE) begin
				D_IN_REG <= D_IN;
				W_COUNTER <= word_width;
				SDA_OUT <= '0;
				write_state <= SENDING_START;
			end
		end
		SENDING_START: begin
			SCL_OUT <= '0;
			write_state <= LOW_SCL;
		end
		LOW_SCL: begin
			SCL_OUT <= '1;
			SDA_OUT <= D_IN_REG[word_width - 1];
			D_IN_REG <= {D_IN_REG[word_width - 2:0], 1'b0};
			write_state <= HIGH_SCL;
		end
		HIGH_SCL: begin
			if (~in_occupied) begin
				SDA_OUT <= '1;
				write_state <= AWAITING_WORD;
			end else begin
				SCL_OUT <= '0;
				write_state <= LOW_SCL;
			end
		end
	endcase
end
endmodule