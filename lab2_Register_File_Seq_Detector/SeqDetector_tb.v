`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/23 22:10:37
// Design Name: 
// Module Name: SeqDetector_tb
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


module SeqDetector_tb;
    reg SEQ;
    reg CLK, RSTn;
    wire OUT;
    
    SeqDetector detectIOI(
        .SEQ(SEQ),
        .CLK(CLK),
        .RSTn(RSTn),
        .OUT(OUT)
    );
    
    initial forever 
        #5 CLK = ~CLK;
    
    initial begin
        CLK = 1;
        RSTn = 1;
        #2  RSTn = 0;
        #7 RSTn = 1;
        
        /// WRITE SEQ
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 0;
        #10 SEQ = 1;
        #10 SEQ = 1;
        #10 SEQ = 1;
        #10 SEQ = 1;
        #10 SEQ = 1;
        
        $finish;
    end
endmodule
