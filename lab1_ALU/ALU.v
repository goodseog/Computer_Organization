`timescale 100ps / 100ps

module ALU( A, B, Cin, OP, C, Cout );
input [15:0] A, B;
input Cin;
input [3:0] OP;
output reg [15:0] C;
output reg Cout;

wire [16:0] sum, sub;

assign sum = A + B + Cin;
assign sub = A - B - Cin;

always@* begin
    case(OP)
		 4'b0000 : begin // OP_ADD
			  C    = sum[15:0];
			  Cout = sum[16];
		 end
		 4'b0001 : begin // OP_SUB
			  C    = sub[15:0];
			  Cout = sub[16];
		 end
		 4'b0010 : begin // OP_ID
			  C    = A;
			  Cout = 0;
		 end
		 4'b0011 : begin // OP_NAND
			  C    = ~(A & B);
			  Cout = 0;
		 end
		 4'b0100 : begin // OP_NOR
			  C    = ~(A | B);
			  Cout = 0;
		 end
		 4'b0101 : begin // OP_XNOR
			  C    = ~(A ^ B);
			  Cout = 0;
		 end
		 4'b0110 : begin // OP_NOT
			  C    = ~A;
			  Cout = 0;
		 end
		 4'b0111 : begin // OP_AND
			  C    = A & B;
			  Cout = 0;
		 end
		 4'b1000 : begin // OP_OR
			  C    = A | B;
			  Cout = 0;
		 end
		 4'b1001 : begin // OP_XOR
			  C    = A ^ B;
			  Cout = 0;
		 end
		 4'b1010 : begin // OP_LRS
			  C    = A >> 1;
			  Cout = 0;
		 end
		 4'b1011 : begin // OP_ARS
			  C    = {A[15], A[15:1]};
			  Cout = 0;
		 end
		 4'b1100 : begin // OP_RR
			  C    = {A[0], A[15:1]};
			  Cout = 0;
		 end
		 4'b1101 : begin // OP_LLS
			  C    = A << 1;
			  Cout = 0;
		 end
		 4'b1110 : begin // OP_ALS
			  C    = A <<< 1;
			  Cout = 0;
		 end
		 4'b1111 : begin // OP_RL
			  C    = {A[14:0], A[15]};
			  Cout = 0;
		 end
    endcase
end
endmodule