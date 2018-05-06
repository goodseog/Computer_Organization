`include "constants.v"

module IF_ID (
    input                   Clk,
    input                   Reset_N,
    input                   IF_ID_Write,
    input                   IF_ID_Flush,
    input                   EX_MEM_MemRW,
    
    input  [`WORD_SIZE-1:0] PCSource,
    input  [`WORD_SIZE-1:0] instruction,

    output [`WORD_SIZE-1:0] IF_ID_PCSource,
    output [`WORD_SIZE-1:0] IF_ID_instruction
);
    reg [`WORD_SIZE-1:0] reg_instruction;
    assign IF_ID_PCSource    = PCSource;
    assign IF_ID_instruction = IF_ID_Flush ? `WORD_SIZE'b0 : reg_instruction ;
    
    always @ ( posedge Clk ) begin
        if     ( !Reset_N )     reg_instruction <= `WORD_SIZE'h0000;
        else if( IF_ID_Flush  ) reg_instruction <= `WORD_SIZE'h0000;
        else if( EX_MEM_MemRW ) reg_instruction <= reg_instruction;
        else if( IF_ID_Write  ) reg_instruction <= instruction;
        else                    reg_instruction <= reg_instruction;
    end
endmodule