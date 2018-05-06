`timescale 1ns/1ns										
`define PERIOD1 100
`define WORD_SIZE 16

module memory_tb();
    reg reset_n;	// active-low RESET signal
	reg clk;		// clock signal	
	
	// Instruction memory interface
	wire i_readM;
	wire i_writeM;
	wire [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_data;		
	
	// Data memory interface
	reg d_readM;
	reg d_writeM;
	reg [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_data;

	// for debuging purpose
	wire [`WORD_SIZE-1:0] num_inst;		// number of instruction during execution
	wire [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	wire is_halted;				// set if the cpu is halted

	// instantiate the unit under test
	Memory NUUT(!clk, reset_n, i_readM, i_writeM, i_address, i_data, d_readM, d_writeM, d_address, d_data);
	
	// initialize inputs
    initial begin
        clk = 0;           // set initial clock value    
        
        reset_n = 1;       // generate a LOW pulse for reset_n
        #( `PERIOD1 / 4 ) reset_n = 0;
        #( `PERIOD1 + `PERIOD1 / 2 ) reset_n = 1;
    end

    // generate the clock
    always #(`PERIOD1/2)clk = ~clk;  // generates a clock (period = `PERIOD1)
    
	initial begin
	   #`PERIOD1 
	   d_readM = 1; d_writeM = 0; d_address = 16'h0000;   
	   #`PERIOD1 
	   #`PERIOD1 
	   #`PERIOD1 
	   #`PERIOD1 
	   #`PERIOD1 
	   #`PERIOD1 
	   #`PERIOD1 
            
	   #`PERIOD1 
	   #`PERIOD1
	   d_readM = 0; d_writeM = 0; d_address = 16'h0000; 
	end	
endmodule