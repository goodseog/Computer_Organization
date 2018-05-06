`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/23 21:54:25
// Design Name: 
// Module Name: SeqDetector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SeqDetector(
    input SEQ,
    input CLK,
    input RSTn,
    output reg OUT
    );
    
    parameter S0 = 3'b00;
    parameter S1 = 3'b01;
    parameter S2 = 3'b10;

	 reg outSEQ;
    reg [2:0] cstate, nstate;

    always@( posedge CLK, negedge RSTn ) begin
        if(!RSTn) cstate <= S0;
        else      cstate <= nstate;
    end
	     
    always @ * begin
        case( cstate )
        S0 : if( SEQ ) nstate = S1;
             else      nstate = S0;
        S1 : if( SEQ ) nstate = S1;
	          else      nstate = S2;
        S2 : if( SEQ ) nstate = S1;
	          else      nstate = S0;
        default :      nstate = S0;
		  endcase
    end
	 
	 always @ * begin
	     case( cstate )
        S2 : if( SEQ ) outSEQ = 1'b1;
	          else      outSEQ = 1'b0;
        default :      outSEQ = 1'b0;
		  endcase
    end
	 
	 always@( posedge CLK, negedge RSTn ) begin
        if(!RSTn) OUT <= 1'b0;
        else      OUT <= outSEQ;
    end
	 
endmodule
