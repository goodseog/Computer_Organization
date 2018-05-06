`include "constants.v"

module EX_MEM(
    input Clk,
    input Reset_N,
    
    input                 ID_EX_WrongPredict, output reg               EX_MEM_WrongPredict,
    input                 ID_EX_JumptoReg , output reg                 EX_MEM_JumptoReg,   
    input[           4:0] ID_EX_ControlSig, output reg[           4:0] EX_MEM_ControlSig,
  
    // For link
    input [`WORD_SIZE-1:0] ID_EX_PCSource   , output reg [`WORD_SIZE-1:0] EX_MEM_PCSource,      
    
    input[`WORD_SIZE-1:0] ID_EX_ALUOut,    output reg[`WORD_SIZE-1:0] EX_MEM_ALUOut,
    input[`WORD_SIZE-1:0] ID_EX_WriteData, output reg[`WORD_SIZE-1:0] EX_MEM_WriteData,
    
    input[           1:0] ID_EX_RegisterRd,output reg[           1:0] EX_MEM_RegisterRd
);

    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            EX_MEM_WrongPredict <= 0;
            EX_MEM_JumptoReg  <= 0;
            EX_MEM_ControlSig <= 0;
            EX_MEM_PCSource   <= 0;
            EX_MEM_ALUOut     <= 0;
            EX_MEM_WriteData  <= 0;
            EX_MEM_RegisterRd <= 0;        
        end
        else begin
            EX_MEM_WrongPredict <= ID_EX_WrongPredict;
            EX_MEM_JumptoReg  <= ID_EX_JumptoReg;
            EX_MEM_ControlSig <= ID_EX_ControlSig;
            EX_MEM_PCSource   <= ID_EX_PCSource;
            EX_MEM_ALUOut     <= ID_EX_ALUOut;
            EX_MEM_WriteData  <= ID_EX_WriteData;
            EX_MEM_RegisterRd <= ID_EX_RegisterRd;
        end
    end
endmodule