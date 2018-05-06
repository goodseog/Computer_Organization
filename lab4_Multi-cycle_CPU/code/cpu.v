`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal
    
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);    
    wire w_IRWrite, w_IDWrite, w_EXWrite, w_MemtoReg,
          w_RegDst, w_ALUSrcB, w_RegWrite ;
    wire [`WORD_SIZE-1:0] w_instruction, w_PCSource, w_next_address,
	                      w_mem_address, w_output_data, w_load_data, w_store_data ;
    
    // ... fill in the rest of the code
	
	// Multi-cycle CPU Control Unit 
    ControlUnit cu ( 
        
        .readM(readM),
        .writeM(writeM),                
        .address(address),
        .output_port(output_port),
        .num_inst(num_inst),
          
        .data(data),
            
        .IRWrite( w_IRWrite ),
        .IDWrite( w_IDWrite ),
        .EXWrite( w_EXWrite ),
        
        .RegWrite( w_RegWrite ),
        .MemtoReg( w_MemtoReg ),
        .RegDst ( w_RegDst ),
        .ALUSrcB( w_ALUSrcB ),
        
        .PCSource( w_PCSource ),        
        .instruction( w_instruction ),
        .next_address( w_next_address ),
        .output_data( w_output_data ),
        .load_data( w_load_data ),                              
        .store_data( w_store_data ),
        
        .inputReady(inputReady),
        .clock(clk),
        .reset_n(reset_n),
        .is_halted(is_halted)    
    );    
    
	// Multi-cycle CPU Datapath
    Datapath dp (        
        
        .IRWrite( w_IRWrite ),
        .IDWrite( w_IDWrite ),
        .EXWrite( w_EXWrite ),
        .RegDst ( w_RegDst ),
        .ALUSrcB( w_ALUSrcB ),
        .RegWrite( w_RegWrite ),
        .MemtoReg( w_MemtoReg ),
        
        .next_address( w_next_address ),
        .output_data( w_output_data ),
        .load_data( w_load_data ),
        .store_data( w_store_data ),
        
        .instruction( w_instruction ),
        .PCSource( w_PCSource ),
        
        .clock(clk),
        .reset_n(reset_n)        
    );
    
endmodule
