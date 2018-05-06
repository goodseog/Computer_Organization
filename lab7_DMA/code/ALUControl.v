`include "opcodes.v"

module ALUControl(
	input[3:0] Opcode,
	input[5:0] Func,
	output reg[3:0] ALUOp
);
	always @ ( Opcode, Func )begin
		case(Opcode)
		`OPCODE_ADI : ALUOp = `OP_ADD; // OP_ADD
		`OPCODE_ORI : ALUOp = `OP_ORR; // OP_ORR
		`OPCODE_LHI : ALUOp = `OP_LHI; // OP_LHI
		`OPCODE_LWD : ALUOp = `OP_ADD;
		`OPCODE_SWD : ALUOp = `OP_ADD;
//		`OPCODE_BNE : ;
//		`OPCODE_BEQ : ;
//		`OPCODE_BGZ : ;
//		`OPCODE_BLZ : ;
//		`OPCODE_JMP : ;
//		`OPCODE_JAL : ; 
		
		`OPCODE_RTYPE : begin // R-type Instruction
			case(Func)
			`FUNC_ADD : ALUOp = `OP_ADD;
			`FUNC_SUB : ALUOp = `OP_SUB;
			`FUNC_AND : ALUOp = `OP_AND;
			`FUNC_ORR : ALUOp = `OP_ORR;
			`FUNC_NOT : ALUOp = `OP_NOT;
			`FUNC_TCP : ALUOp = `OP_TCP; // TCP : Two's ComPliment
			`FUNC_SHL : ALUOp = `OP_SHL;
			`FUNC_SHR : ALUOp = `OP_SHR;
			`FUNC_WWD : ALUOp = `OP_ID;
			default :   ALUOp = `OP_ADD ;
			endcase		
		end
		
		default : ALUOp = `OP_ADD;		
		endcase
	end
endmodule
