`include "constants.v"
`include "opcodes.v"
 
module NextAddress (
    output reg[`WORD_SIZE-1:0] next_address,

    input[`WORD_SIZE-1:0] PCSource,
    input signed[`WORD_SIZE-1:0] rs,
    input[`WORD_SIZE-1:0] BranchTarget,    
    input[11:0]           JumpTarget,
    input[3:0]            Opcode,
    input[5:0]            Func,
    input                 Zero
);
    
    always @ (*) begin
        case( Opcode )
        `OPCODE_BNE :
            if( Zero ) next_address = PCSource + 1;
            else       next_address = PCSource + 1 + BranchTarget;
        `OPCODE_BEQ :
            if( Zero ) next_address = PCSource + 1 + BranchTarget;
            else       next_address = PCSource + 1;
        `OPCODE_BGZ :
            if( rs > 0 ) next_address = PCSource + 1 + BranchTarget;
            else         next_address = PCSource + 1;
        `OPCODE_BLZ : 
            if( rs < 0 ) next_address = PCSource + 1 + BranchTarget;
            else         next_address = PCSource + 1;
        `OPCODE_JMP,
        `OPCODE_JAL :  next_address = { PCSource[15:12], JumpTarget } ;
        `OPCODE_RTYPE :
            if ( Func == `FUNC_JPR | Func == `FUNC_JRL )
                next_address = rs ;
            else
                next_address = PCSource + 1;        
        default : next_address = PCSource + 1;               
        endcase   
    end
endmodule