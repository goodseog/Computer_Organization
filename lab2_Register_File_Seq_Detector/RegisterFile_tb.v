`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/23 22:52:42
// Design Name: 
// Module Name: RegisterFile_tb
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


module RegisterFile_tb;

    wire [15:0] data1, data2;
    
    reg [1:0] addr1, addr2, addr3;
    reg [15:0] data3;
    reg CLK, WE;
    
    RegisterFile rf(
        .Addr1(addr1),
        .Addr2(addr2),
        .Addr3(addr3),
        .Data1(data1),
        .Data2(data2),
        .Data3(data3),
        .Clock(CLK),
        .Write(WE)
    );
    
    initial forever
        #5 CLK = ~CLK;
    
    initial begin        
        CLK=1;
        
        addr1 = 2'b00;
        addr2 = 2'b01;
		  
        /// WRITE DATA
        #8  WE = 1'b1;
            addr3 = 2'b00;
            data3 = 2;
        #10 WE = 1'b1;
            addr3 = 2'b01;
            data3 = 8;
        #10 WE = 1'b1;
            addr3 = 2'b10;
            data3 = 32;
        #10 WE = 1'b1;
            addr3 = 2'b11;
            data3 = 128;
        #10 WE = 1'b0;
		      data3 = 1024;
        // END WRITE
        #20 addr1 = 2'b10;
            addr2 = 2'b11;
        #20 
            WE = 1'b1;
        #10 WE = 1'b0;
        #20
        $finish;
            
    end
    
endmodule