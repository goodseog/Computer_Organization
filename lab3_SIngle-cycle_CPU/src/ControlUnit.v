`define WORD_SIZE 16  

`include "opcodes.v"

module ControlUnit(
	output reg RegDst,
	output reg Jump,
	output reg Branch,
	output reg MemtoReg,
	output reg MemRead,
	output reg MemWrite,
	output reg[3:0] ALUOp,
	output reg ALUSrcB,
	output reg RegWrite,
	output reg RegOutput,
	
	input [3:0] Opcode,
	input [5:0] funct
);
	
	always @ * begin
		case(Opcode)
		`OPCODE_ADI,
		`OPCODE_ORI,
		`OPCODE_LHI : begin // I-type Instruction, ADI, ORI, LHI
			RegDst   = 0;
			Jump      = 0;
			Branch   = 0;
			MemtoReg = 0;
			MemRead  = 0;
			MemWrite = 0;
			ALUOp    = Opcode; 
			ALUSrcB  = 1;
			RegWrite = 1;
			RegOutput = 0;
		end
		`OPCODE_JMP : begin
			RegDst   = 0;
			Jump      = 1;
			Branch   = 0;
			MemtoReg = 0;
			MemRead  = 0;
			MemWrite = 0;
			ALUOp    = Opcode;
			ALUSrcB  = 0;
			RegWrite = 0;
			RegOutput = 0;
		end		
		`OPCODE_RTYPE : begin // R-type Instruction
			case(funct)
			`FUNC_WWD : begin // WWD
				RegDst   = 0;
				Jump     = 0;
				Branch   = 0;
				MemtoReg = 0;
				MemRead  = 0;
				MemWrite = 0;
				ALUOp    = Opcode; 
				ALUSrcB  = 0;
				RegWrite = 0;
				RegOutput = 1;
			end
			default : begin // ALU
				RegDst   = 1;
				Jump     = 0;
				Branch   = 0;
				MemtoReg = 0;
				MemRead  = 0;
				MemWrite = 0;
				ALUOp    = Opcode; 
				ALUSrcB  = 0;
				RegWrite = 1;
				RegOutput = 0;	
			end
			endcase	
		end
		default : begin
			RegDst   = 0;
            Jump     = 0;
            Branch   = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            ALUOp    = Opcode; 
            ALUSrcB  = 0;
            RegWrite = 0;
            RegOutput = 0;
        end	
		endcase	
	end

endmodule
