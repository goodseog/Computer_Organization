`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/23 22:52:42
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input [1:0] Addr1,
    input [1:0] Addr2,
    input [1:0] Addr3,
    
    output[15:0] Data1,
    output[15:0] Data2,
    input [15:0] Data3,
    
    input Write,
    input Clock
    );

    reg[15:0] register[3:0];

    assign Data1 = register[Addr1];
    assign Data2 = register[Addr2]; 
    
    always @ ( posedge Clock )
        if( Write )
		      register[Addr3] <= Data3;
				
endmodule
