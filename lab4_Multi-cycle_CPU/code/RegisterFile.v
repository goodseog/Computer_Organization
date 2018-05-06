`timescale 1ns / 1ps

module RegisterFile(
    input [1:0] Addr1,
    input [1:0] Addr2,
    input [1:0] Addr3,
    
    output[15:0] Data1,
    output[15:0] Data2,
    input [15:0] Data3,
    
    input Write,
    input clk,
    input reset_n
);

    reg[15:0] register[3:0];

    assign Data1 = register[Addr1];
    assign Data2 = register[Addr2]; 
    
    always @ ( posedge clk, negedge reset_n )
    	if( !reset_n ) begin
    		register[0] = 16'b0;
    		register[1] = 16'b0;
    		register[2] = 16'b0;
    		register[3] = 16'b0;
    	end
    	else
		    if( Write )
				  register[Addr3] <= Data3;
endmodule
