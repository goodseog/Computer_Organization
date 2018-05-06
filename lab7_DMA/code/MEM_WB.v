`include "constants.v"

module MEM_WB (
    input Clk,
    input Reset_N,
    input EX_MEM_MemRW,
    
    input[           2:0] EX_MEM_ControlSig, output reg[           2:0] MEM_WB_ControlSig,
    
    input[`WORD_SIZE-1:0] EX_MEM_PCSource,   output reg[`WORD_SIZE-1:0] MEM_WB_PCSource,
    
    input[`WORD_SIZE-1:0] EX_MEM_MemData,    output reg[`WORD_SIZE-1:0] MEM_WB_MemData,
    input[`WORD_SIZE-1:0] EX_MEM_ALUOut ,    output reg[`WORD_SIZE-1:0] MEM_WB_ALUOut,
    
    input[           1:0] EX_MEM_RegisterRd, output reg[           1:0] MEM_WB_RegisterRd
);

    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            MEM_WB_ControlSig <= 0;
            MEM_WB_PCSource   <= 0;
            MEM_WB_MemData    <= 0;
            MEM_WB_ALUOut     <= 0;
            MEM_WB_RegisterRd <= 0;
        end
        else if( EX_MEM_MemRW ) begin
            MEM_WB_ControlSig <= MEM_WB_ControlSig;
            MEM_WB_PCSource   <= MEM_WB_PCSource;
            MEM_WB_MemData    <= MEM_WB_MemData;
            MEM_WB_ALUOut     <= MEM_WB_ALUOut;
            MEM_WB_RegisterRd <= MEM_WB_RegisterRd;
        end
        else begin
            MEM_WB_ControlSig <= EX_MEM_ControlSig;
            MEM_WB_PCSource   <= EX_MEM_PCSource;
            MEM_WB_MemData    <= EX_MEM_MemData;
            MEM_WB_ALUOut     <= EX_MEM_ALUOut;
            MEM_WB_RegisterRd <= EX_MEM_RegisterRd;
        end
    end
endmodule