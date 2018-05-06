`include "opcodes.v"
`include "constants.v"

module BranchDecision(
    input [`WORD_SIZE-1:0] ID_EX_instruction,
    input signed [`WORD_SIZE-1:0] Data1,
    input signed [`WORD_SIZE-1:0] Data2,
    output Decision
);

    wire [4:0] Opcode;
    wire [5:0] Func;
    
    assign Opcode = ID_EX_instruction[15:12];
    assign Func   = ID_EX_instruction[ 5: 0];
    
    assign Decision = (( Opcode == `OPCODE_BNE ) && ( Data1 != Data2 )) ||
                      (( Opcode == `OPCODE_BEQ ) && ( Data1 == Data2 )) ||
                      (( Opcode == `OPCODE_BGZ ) && ( Data1 > 0 )) ||
                      (( Opcode == `OPCODE_BLZ ) && ( Data1 < 0 ));

endmodule