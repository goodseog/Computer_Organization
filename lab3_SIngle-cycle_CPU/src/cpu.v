///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: 
// Description: 

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size
`define READ_DELAY 30   // delay before memory data is ready
`define STABLE_TIME 10  // time data is stable after end-of-read

// INCLUDE files
`include "opcodes.v"    // "opcode.v" consists of "define" statements for
                        // the opcodes and function codes for all instructions

// MODULE DECLARATION
module cpu (
  output reg readM,                   // read from memory
  output reg[`WORD_SIZE-1:0] address,// current address for data (PC addr)
  inout [`WORD_SIZE-1:0] data,        // data being input or output (instruction mem)
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal

  // for debuging/testing purpose
  output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
  output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
); 

    reg[`WORD_SIZE-1:0] instruction;

	wire w_RegDst, w_Jump, w_Branch, w_MemtoReg, w_MemRead,
	     w_MemWrite, w_ALUSrcB, w_RegWrite, w_RegOutput;
	wire[3:0] w_ALUOp;
	
	wire[`WORD_SIZE-1:0] w_nxt_address;
	wire[`WORD_SIZE-1:0] w_output_port;
		
	assign output_port = w_output_port;
	
    // ... fill in the rest of the code
    ControlUnit cu (
    	.RegDst   (w_RegDst),
    	.Jump     (w_Jump),
    	.Branch   (w_Branch),
    	.MemtoReg (w_MemtoReg),
    	.MemRead  (w_MemRead),
    	.MemWrite (w_MemWrite),
    	.ALUOp    (w_ALUOp),
    	.ALUSrcB  (w_ALUSrcB),
    	.RegWrite (w_RegWrite),
    	.RegOutput(w_RegOutput),
		
		.Opcode(instruction[15:12]),
		.funct(instruction[5:0])
    );
    
    
	Datapath dp(
		.instruction(instruction),
		.cur_address(address),
		.nxt_address(w_nxt_address),
		.output_port(w_output_port),
		
		// links with Control Unit		
		.RegDst   (w_RegDst),
    	.Jump     (w_Jump),
    	.Branch   (w_Branch),
    	.MemtoReg (w_MemtoReg),
    	.MemRead  (w_MemRead),
    	.MemWrite (w_MemWrite),
    	.ALUOp    (w_ALUOp),
    	.ALUSrcB  (w_ALUSrcB),
    	.RegWrite (w_RegWrite),
    	.RegOutput(w_RegOutput),
    	
    	.clk      (clk),
    	.reset_n  (reset_n)
	);
	
	always @ ( posedge clk, negedge reset_n ) begin
		if( !reset_n ) begin
			instruction <= `WORD_SIZE'b0;
			num_inst    <= 0;
			readM       <= 0;
			address     <= 0;
		end
		else begin
		    readM       <= 1;
		    #`READ_DELAY #(`STABLE_TIME-1)
		    instruction <= data;
            num_inst    <= num_inst + 1;
            readM       <= 0;
            #`STABLE_TIME
            address     <= w_nxt_address;            			
		end
	end

endmodule
//////////////////////////////////////////////////////////////////////////
