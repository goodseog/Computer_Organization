// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"

module Datapath(
	
	// Control signals from control unit
    input IRWrite,   // write instruction in STATE_IF
    input IDWrite,   // write register file data in STATE_ID
    input EXWrite,   // Deprecated.
    input RegDst,    // select write address ; rt(0) | rd(1)
    input RegWrite,  // Register file write  ; STATE_A_EX(case by case), STATE_B_WB(LWD)
    input MemtoReg,  // select write data    ; ALUout(0) | MEMout(1)
    input ALUSrcB,   // select source B data ; data2 (0) | Extended imm (1)
	
	// Data inputs from control unit
	input [`WORD_SIZE-1:0] instruction, // instruction input in STATE_IF
	input [`WORD_SIZE-1:0] PCSource,    // current PC input
	input [`WORD_SIZE-1:0] load_data,   // Load data in STATE_B_MEM
		
	// Output results to control unit
	output[`WORD_SIZE-1:0] next_address, // Next address
	output[`WORD_SIZE-1:0] output_data,  // ALU output 
	output[`WORD_SIZE-1:0] store_data,   // store data output in STATE_B_MEM
	
	// Basic signals
	input clock,
	input reset_n
);
    wire w_Zero;
    wire[1:0] w_rdest, w_write_address;
    wire[3:0] w_OP;
    wire[`WORD_SIZE-1:0] w_instruction, w_data1, w_data2, w_data3, w_write_data,
                          w_A, w_B, w_C, w_Boprand, w_immExt, w_ALUout, w_MEMout ;
    
    wire isJALJRL;
    
    assign store_data   = w_B;
    assign output_data  = w_ALUout;
    assign isJALJRL = (   instruction[15:12] == `OPCODE_JAL   ) ||
	                  ( ( instruction[15:12] == `OPCODE_RTYPE ) && ( instruction[5:0] == `FUNC_JRL ) ) ;
    
	
	// IR ; write instruction in STATE_IF.
    Register instruction_register (
        .in( instruction ),
        .clock(clock),
        .write(IRWrite),
        .out( w_instruction )
    );
	    
	// Register file ; same as single cycle cpu rf
    RegisterFile rf(
        .Addr1( w_instruction[11:10] ),
        .Addr2( w_instruction[ 9: 8] ),
        .Addr3( w_write_address ),
        
        .Data1( w_data1 ),
        .Data2( w_data2 ),
        .Data3( w_write_data ),
        
        .Write( RegWrite ),
        .clk( clock ),
        .reset_n( reset_n )
    );
        
	// Addr1 data register in STATE_ID
    Register rs_register (
        .in( w_data1 ),
        .write( IDWrite ),
        .clock(clock),
        .out( w_A )
    );
    
	// Addr2 data register in STATE_ID
    Register rt_register (
        .in( w_data2 ),
        .write( IDWrite ),
        .clock(clock),
        .out( w_B )
    );
    
	// Sign extend module
    SignExtend sex(
        .in( instruction[7:0] ),
        .out( w_immExt )
    );
    
	// Multiplex ALU source B either [read from rf ; 0] or [ sign extended ; 1]
    Mux mux_oprand(
        .A0( w_B ),
        .A1( w_immExt ),
        .sel( ALUSrcB ),
        .S0( w_Boprand )
    );
    
	// Get Opcode(inst[15:12]) & Func(inst[5:0]) and choose Operation
    ALUControl aluc (
        .ALUOp( instruction[15:12] ),
        .funct( instruction[ 5: 0] ),
        .OP( w_OP )
    );
    
	
	// ALU ; for execute
    ALU alu (
        .A( w_A ),
        .B( w_Boprand ),
        .Cin( 0 ),
        .OP( w_OP ),
        .C( w_ALUout ),
        .Cout(),
        .Zero( w_Zero )
    );
    
    /* Deprecated ; it STATE_EX controled by control signal, not register
    Register ALUout_register (
        .in( w_C ),
        .write( EXWrite ),
        .clock( clock ),
        .out( w_ALUout )
    );
    */
    
	// Multiplex write data either [ALUout ; 0] or [MEMout ; 1]
    Mux mux_writedata(
        .A0( w_ALUout ),
        .A1( load_data ),
        .sel( MemtoReg ),
        .S0( w_data3 )
    );
	
	// Multiplex write address
	// if JAL or JRL, it writes data [PC] in address $2	
	Mux mux_writedata_JALJRL (
            .A0( w_data3 ),
            .A1( PCSource + 1 ),
            .sel( isJALJRL ),
            .S0( w_write_data )
    );    
	
	// Multiplex write address either [rt ; 0] or [rd ; 1]
    Mux mux_rdest (
        .A0( w_instruction[ 9: 8] ),
        .A1( w_instruction[ 7: 6] ),
        .sel( RegDst ),
        .S0( w_rdest )
    );
    
	// Multiplex write address
	// if JAL or JRL, it writes data [PC] in address $2
    Mux mux_rdest_JALJRL (
        .A0( w_rdest ),
        .A1( 2'b10 ),
        .sel( isJALJRL ),
        .S0( w_write_address )
    );
    
    // NextAddress module ;
    NextAddress na (
        .next_address(next_address),
    
        .PCSource(PCSource),
        .BranchTarget( w_immExt ),
        .rs( w_A ), // for BGZ, BLZ
        .JumpTarget( w_instruction[11:0] ),
        .Opcode( w_instruction[15:12] ),
        .Func( w_instruction[5:0] ),
        .Zero( w_Zero )
    );       
    
    
endmodule
