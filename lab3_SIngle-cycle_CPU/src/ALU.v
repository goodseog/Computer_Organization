`timescale 100ps / 100ps

`include "opcodes.v"

module ALU( A, B, Cin, OP, C, Cout, Zero );
input [15:0] A, B;
input Cin;
input [3:0] OP;
output reg [15:0] C;
output reg Cout;
output Zero;

wire [16:0] sum, sub;

assign sum  = A + B + Cin;
assign sub  = A - B - Cin;
assign Zero = (A == B)? 1'b1 : 1'b0 ;

always@* begin
    case(OP)
		 `OP_ADD : begin // OP_ADD
			  C    = sum[15:0];
			  Cout = sum[16];
		 end
		 `OP_SUB : begin // OP_SUB
			  C    = sub[15:0];
			  Cout = sub[16];
		 end
		 `OP_ID : begin // OP_ID
			  C    = A;
			  Cout = 0;
		 end
		 `OP_LHI : begin // OP_LHI
			  C    = {B[7:0], 8'b0000_0000};
			  Cout = 0;
		 end
		 `OP_NOR : begin // OP_NOR
			  C    = ~(A | B);
			  Cout = 0;
		 end
		 `OP_XNOR : begin // OP_XNOR
			  C    = ~(A ^ B);
			  Cout = 0;
		 end
		 `OP_NOT : begin // OP_NOT
			  C    = ~A;
			  Cout = 0;
		 end
		 `OP_AND : begin // OP_AND
			  C    = A & B;
			  Cout = 0;
		 end
		 `OP_OR : begin // OP_OR
			  C    = A | B;
			  Cout = 0;
		 end
		 `OP_XOR : begin // OP_XOR
			  C    = A ^ B;
			  Cout = 0;
		 end
		 `OP_LRS : begin // OP_LRS
			  C    = A >> 1;
			  Cout = 0;
		 end
		 `OP_ARS : begin // OP_ARS
			  C    = {A[15], A[15:1]};
			  Cout = 0;
		 end
		 `OP_RR : begin // OP_RR
			  C    = {A[0], A[15:1]};
			  Cout = 0;
		 end
		 `OP_LLS : begin // OP_LLS
			  C    = A << 1;
			  Cout = 0;
		 end
		 `OP_ALS : begin // OP_ALS
			  C    = A <<< 1;
			  Cout = 0;
		 end
		 `OP_RL : begin // OP_RL
			  C    = {A[14:0], A[15]};
			  Cout = 0;
		 end
    endcase
end
endmodule