`timescale 100ps / 100ps

`include "opcodes.v"

module ALU(  
    input [15:0] A, B,
    input Cin,
    input [3:0] OP,
    output reg [15:0] C,
    output reg Cout,
    output Zero
);

wire [16:0] sum, sub;

assign sum  = A + B + Cin;
assign sub  = A - B - Cin;
assign Zero = (A == B)? 1'b1 : 1'b0 ;

always @ * begin
    case(OP)
    `OP_ADD : begin // OP_ADD
        C    = sum[15:0];
        Cout = sum[16];
    end
    `OP_SUB : begin // OP_SUB
        C    = sub[15:0];
        Cout = sub[16];
    end
    `OP_AND : begin // OP_AND
        C    = A & B;
        Cout = 0;
    end
    `OP_ORR : begin // OP_OR
        C    = A | B;
        Cout = 0;
    end
    `OP_NOT : begin // OP_NOT
        C    = ~A;
        Cout = 0;
    end
    `OP_TCP : begin // OP_TCP
        C    = ~A + 1;
        Cout = 0;
    end
    `OP_SHL : begin // OP_SHL
        C    = {A[14:0], 1'b0};
        Cout = 0; 
    end    
    `OP_SHR : begin // OP_SHR
        C    = {A[15], A[15:1]};
        Cout = 0; 
    end
    `OP_ID : begin // OP_ID
        C    = A;
        Cout = 0;
    end    
    `OP_LHI : begin // OP_LHI
        C    = {B[7:0], 8'b0000_0000};
        Cout = 0;
    end
    default :
        Cout = 1;
    endcase
end
endmodule