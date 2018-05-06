`include "opcodes.v"

module ALUControl(
	input[3:0] ALUOp,
	input[5:0] funct,
	output reg[3:0] OP
);
	always @ ( ALUOp, funct )begin
		case(ALUOp)
		`OPCODE_ADI : OP = `OP_ADD; // OP_ADD
		`OPCODE_ORI : OP = `OP_OR ; // OP_ORR
		`OPCODE_LHI : OP = `OP_LHI; // OP_LHI
//		`OPCODE_LWD : ;
//		`OPCODE_SWD : ;
//		`OPCODE_BNE : ;
//		`OPCODE_BEQ : ;
//		`OPCODE_BGZ : ;
//		`OPCODE_BLZ : ;
//		`OPCODE_JMP : ;
//		`OPCODE_JAL : ; 
		
		`OPCODE_RTYPE : begin // R-type Instruction
			case(funct)
			`FUNC_ADD : OP = `OP_ADD;
			`FUNC_SUB : OP = `OP_SUB;
			`FUNC_AND : OP = `OP_AND;
			`FUNC_ORR : OP = `OP_OR ;
			`FUNC_NOT : OP = `OP_NOT;
			`FUNC_TCP : ; // TCP : Two's ComPliment
			`FUNC_SHL : OP = `OP_ALS;
			`FUNC_SHR : OP = `OP_ARS;
			default :   OP = `OP_ID ;
			endcase		
		end
		
		default : OP = `OP_ID;		
		endcase
	end
endmodule
