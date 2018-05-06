`include "constants.v"

module ID_EX (

    input   Clk,
    input   Reset_N,
    input   EX_MEM_MemRW,

    // Contorl Signals 
    input [15:0]IF_ID_ControlSig     , output reg [15:0] ID_EX_ControlSig  ,
   
    // Branch
    input [`WORD_SIZE-1:0] IF_ID_instruction, output reg [`WORD_SIZE-1:0] ID_EX_instruction,
    input [`WORD_SIZE-1:0] IF_ID_PCBranch   , output reg [`WORD_SIZE-1:0] ID_EX_PCBranch  ,
    
    // For link
    input [`WORD_SIZE-1:0] IF_ID_PCSource   , output reg [`WORD_SIZE-1:0] ID_EX_PCSource,  
   
    // Datas
    input [`WORD_SIZE-1:0] IF_ID_DataRs     , output reg [`WORD_SIZE-1:0] ID_EX_DataRs     ,
    input [`WORD_SIZE-1:0] IF_ID_DataRt     , output reg [`WORD_SIZE-1:0] ID_EX_DataRt     ,
    input [`WORD_SIZE-1:0] IF_ID_DataImm    , output reg [`WORD_SIZE-1:0] ID_EX_DataImm    ,
    input [`WORD_SIZE-1:0] IF_ID_RegisterRs , output reg [`WORD_SIZE-1:0] ID_EX_RegisterRs ,
    input [`WORD_SIZE-1:0] IF_ID_RegisterRt , output reg [`WORD_SIZE-1:0] ID_EX_RegisterRt ,
    input [`WORD_SIZE-1:0] IF_ID_RegisterRd , output reg [`WORD_SIZE-1:0] ID_EX_RegisterRd 
);

    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            ID_EX_ControlSig  <= 0;
            ID_EX_PCSource    <= 0;
            ID_EX_instruction <= 0;
            ID_EX_PCBranch    <= 0;
            ID_EX_DataRs      <= 0;
            ID_EX_DataRt      <= 0;
            ID_EX_DataImm     <= 0;
            ID_EX_RegisterRs  <= 0;
            ID_EX_RegisterRt  <= 0;
            ID_EX_RegisterRd  <= 0;            
        end
        else if ( EX_MEM_MemRW ) begin // stop when cpu access memory
            ID_EX_ControlSig  <= ID_EX_ControlSig;
            ID_EX_PCSource    <= ID_EX_PCSource;
            ID_EX_instruction <= ID_EX_instruction;
            ID_EX_PCBranch    <= ID_EX_PCBranch;
            ID_EX_DataRs      <= ID_EX_DataRs;
            ID_EX_DataRt      <= ID_EX_DataRt;
            ID_EX_DataImm     <= ID_EX_DataImm;
            ID_EX_RegisterRs  <= ID_EX_RegisterRs;
            ID_EX_RegisterRt  <= ID_EX_RegisterRt;
            ID_EX_RegisterRd  <= ID_EX_RegisterRd;
        end
        else begin
            ID_EX_ControlSig  <= IF_ID_ControlSig;
            ID_EX_PCSource    <= IF_ID_PCSource;
            ID_EX_instruction <= IF_ID_instruction;
            ID_EX_PCBranch    <= IF_ID_PCBranch;
            ID_EX_DataRs      <= IF_ID_DataRs;
            ID_EX_DataRt      <= IF_ID_DataRt;
            ID_EX_DataImm     <= IF_ID_DataImm;
            ID_EX_RegisterRs  <= IF_ID_RegisterRs;
            ID_EX_RegisterRt  <= IF_ID_RegisterRt;
            ID_EX_RegisterRd  <= IF_ID_RegisterRd;
        end
    end
endmodule