// States define
`define STATE_IF    3'b000
`define STATE_ID    3'b001
`define STATE_A_EX  3'b010
`define STATE_B_EX  3'b011
`define STATE_B_MEM 3'b100
`define STATE_B_WB  3'b101
`define STATE_INVALID 3'b111

`include "opcodes.v"
`include "constants.v"

module ControlUnit(
    
    // Signals for Memory
    output reg readM,							// Read from memory			; data <- Memory[address]
    output reg writeM,							// Write to memory			; Memory[address] <- data
    output reg [`WORD_SIZE-1:0] address,		// Memory access address	; either instruction or load data
    output reg [`WORD_SIZE-1:0] output_port,	// WWD for test case		; output_port <= output_data 
    output reg [`WORD_SIZE-1:0] num_inst,       // +1 when instr. execute	; end of A_EX or B_WB
    
    inout[`WORD_SIZE-1:0] data,					// inout port between memory - control unit
												// LWD : readM  & data writeen by memory
												// SWD : writeM & data written by control unit						
    
    // Control Signals for datapath
    output IRWrite, // Datapath instruction register update    (STATE_IF)
    output IDWrite, // Datapath register file read data update (STATE_ID)
    output EXWrite, // Deprecated. Useless register remove..
    
    output reg RegWrite, // Write Register file sig in STATE_A_EX(case by case) & STATE_B_WB(LWD)
    output MemtoReg,     // Mux write datas from [memory] or [ALUout] 
    output RegDst,       // Mux register destination. rt or rd
    output ALUSrcB,      // Mux ALU source B. register file data or Extended imm value
    
	// Data transfer with datapath
    output reg [`WORD_SIZE-1:0] PCSource,     // Send current PC to datapath
    output reg [`WORD_SIZE-1:0] instruction,  // Send current instructino to datapath
    output reg [`WORD_SIZE-1:0] load_data,    // Send load_data (STATE_B_MEM, LWD to datapath
    
    input[`WORD_SIZE-1:0] next_address, // Input next_address decided from datapath
    input[`WORD_SIZE-1:0] output_data,  // Input ALU result from datapath
    input[`WORD_SIZE-1:0] store_data,   // Input store data(SWD) from datapath
	
	// Basic
	input  inputReady, // memory interface
	input  clock,
	input  reset_n,
	output reg is_halted // HLT instruction executed. => 1
);
    reg[2:0] curr_state, next_state;
    
    assign data = writeM ? store_data : `WORD_SIZE'bz;
    
    always @ ( posedge clock, negedge reset_n ) begin
        if( !reset_n ) begin
            curr_state <= `STATE_IF;
            address  <= `WORD_SIZE'd0;
            PCSource <= `WORD_SIZE'd0;
            num_inst <= `WORD_SIZE'd0;
            is_halted <= 0;
        end
        else begin
            if( (curr_state == `STATE_A_EX) || (curr_state == `STATE_B_WB) )  num_inst <= num_inst + 1;
            curr_state <= next_state;
        end
    end
    
    always @ ( curr_state ) begin
        case( curr_state )
        `STATE_IF :
			next_state = `STATE_ID;
        `STATE_ID : begin
            case( instruction[15:12] ) // opcode
            `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI,
            `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ,
            `OPCODE_JMP, `OPCODE_JAL, `OPCODE_RTYPE : 
                next_state = `STATE_A_EX;
            `OPCODE_LWD, `OPCODE_SWD :
                next_state = `STATE_B_EX;
            default :
                next_state = `STATE_INVALID; // Exception occured !! 
            endcase
        end
        `STATE_A_EX  : next_state = `STATE_IF;
        `STATE_B_EX  : next_state = `STATE_B_MEM;
        `STATE_B_MEM : next_state = `STATE_B_WB;
        `STATE_B_WB  : next_state = `STATE_IF;
        
        default   : next_state = `STATE_INVALID; // Exception occured !!
        endcase
    end
    
	// update instruction when memory ACK
    always @ ( posedge inputReady ) begin 
        if     ( curr_state == `STATE_IF    ) instruction <= data;
        else if( curr_state == `STATE_B_MEM ) load_data   <= data; 
    end
    
	// Update 16bit datas of datapath
    always @ ( posedge clock ) begin 
        case( curr_state )
        `STATE_A_EX : begin  // set next PC = (PC + 4, Branch, Jump)
            address  <= next_address;
            PCSource <= next_address;
            if( (instruction[15:12] == `OPCODE_RTYPE) & (instruction[5:0] == `FUNC_WWD ) )
                 output_port <= output_data;
            if( (instruction[15:12] == `OPCODE_RTYPE) & (instruction[5:0] == `FUNC_HLT ) )
                is_halted <= 1;
        end
        `STATE_B_EX  : begin  // set read/write memory address
            address <= output_data;
        end  
        `STATE_B_MEM : begin
            load_data <= data;            
        end
        `STATE_B_WB : begin // set next PC = PC + 4
            address  <= next_address;
            PCSource <= next_address;
        end
        default : begin 
            address <= address;
            PCSource <= PCSource;
        end
        endcase
    end
    
    // Set control signals
    assign IRWrite  = ( curr_state == `STATE_IF ) ;
    assign IDWrite  = ( curr_state == `STATE_ID );
    assign EXWrite  = ( curr_state == `STATE_A_EX ) | ( curr_state == `STATE_B_EX ) ; 
    
    assign RegDst   = ( instruction[15:12] == `OPCODE_RTYPE );
    assign MemtoReg = ( curr_state == `STATE_B_WB );
    assign ALUSrcB  = ( instruction[15:12] == `OPCODE_ADI ) |
                      ( instruction[15:12] == `OPCODE_ORI ) |
                      ( instruction[15:12] == `OPCODE_LHI ) |
                      ( instruction[15:12] == `OPCODE_LWD ) |
                      ( instruction[15:12] == `OPCODE_SWD ) ;
    
	// Set control signals
    always @ ( curr_state ) begin 
        case( curr_state )
        `STATE_IF : begin
            readM  = 1; 
            writeM = 0;
            RegWrite = 0;
        end
        `STATE_ID : begin
            readM  = 0;
            writeM = 0;
            RegWrite = 0;       
        end
        `STATE_A_EX : begin
            readM    = 0;
            writeM   = 0;
            case( instruction[15:12] )
            `OPCODE_RTYPE :
                case( instruction[5:0] )
                `FUNC_WWD, `FUNC_JPR, `FUNC_HLT : RegWrite = 0;
                default :                         RegWrite = 1;
                endcase
            `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI, `OPCODE_JAL : RegWrite = 1;
            default : RegWrite = 0; 
            endcase
            
        end
        `STATE_B_EX : begin
            readM  = 0;
            writeM = 0; 
            RegWrite = 0;
        end
        `STATE_B_MEM : begin 
            readM  = ( instruction[15:12] == `OPCODE_LWD );
            writeM = ( instruction[15:12] == `OPCODE_SWD );
            RegWrite = 0;
        end
        `STATE_B_WB : begin
            readM  = 0;
            writeM = 0;
            RegWrite = ( instruction[15:12] == `OPCODE_LWD );
        end
        default : ;
        endcase
    end
endmodule
