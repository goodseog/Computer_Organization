`include "constants.v"

module Datapath (
    input Clk,
    input Reset_N,
    
    input  [`WORD_SIZE-1:0] instruction,
    input  [`WORD_SIZE-1:0] PCSource,
    
    output reg [`WORD_SIZE-1:0] num_inst, 
    output reg [`WORD_SIZE-1:0] output_port,
    output                      is_halted,
    
//                              15       14        13      12    11     10        9     8-5       4        3        2         1        0
//    assign ControlSig  = { isHalted, Branch, JumptoReg , Jump, isWWD, RegDst, ALUSrc, ALUOp, MemRead, MemWrite, MemtoReg, RegLink, RegWrite };
    input  [          15:0] ControlSig,
    
    output [`WORD_SIZE-1:0] IF_ID_instruction, 
    output [`WORD_SIZE-1:0] PCNext,
    output                  PCWrite,
    
    output                  EX_MEM_MemRead,
    output                  EX_MEM_MemWrite,
    output [`WORD_SIZE-1:0] EX_MEM_ALUOut,
    output [`WORD_SIZE-1:0] EX_MEM_WriteData,
    input  [`WORD_SIZE-1:0] EX_MEM_MemData,
    
    // Notice when memory access finished.
    input d_doneM
); 

    wire
        RegWrite, IF_ID_RegWrite, ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite,
        MemtoReg, IF_ID_MemtoReg, ID_EX_MemtoReg, EX_MEM_MemtoReg, MEM_WB_MemtoReg,
        MemRead , IF_ID_MemRead , ID_EX_MemRead , EX_MEM_JumptoReg,
        MemWrite, IF_ID_MemWrite, ID_EX_MemWrite,
        ALUOp   , IF_ID_ALUOp   , ID_EX_ALUOp   ,
        RegDst  , IF_ID_RegDst  , ID_EX_RegDst  , EX_MEM_WrongPredict,
                  IF_ID_Write,    WrongPredict  , EX_MEM_MemRW,
                  IF_ID_ControlSel,
        PCSrc,
        Stall,
        HarzardDetection;

    wire [1:0]
        IF_ID_RegisterRs, ID_EX_RegisterRs, EX_MEM_RegisterRd, MEM_WB_RegisterRd,  WB_WriteAddr,
        IF_ID_RegisterRt, ID_EX_RegisterRt,                                        
        IF_ID_RegisterRd, ID_EX_RegisterRd,
                          ID_EX_dest,
        ForwardA,
        ForwardB;
    
    wire [2:0]
        MEM_WB_ControlSig;
    
    wire [4:0]
        EX_MEM_ControlSig;
    
    wire [7:0]
        IF_ID_Imm;
    
    wire [15:0]
        IF_ID_ControlSig, ID_EX_ControlSig;
    
    wire [`WORD_SIZE-1:0]
        IF_ID_PCSource, ID_EX_PCSource, EX_MEM_PCSource, MEM_WB_PCSource,
        IF_ID_PCBranch, ID_EX_PCBranch, 
        IF_ID_PCJump,
        IF_ID_DataRs,   ID_EX_DataRs,
        IF_ID_DataRt,   ID_EX_DataRt,
        IF_ID_DataImm,  ID_EX_DataImm,       
                        ID_EX_DataA,
                        ID_EX_DataB,
                        ID_EX_ForwardB,
                        ID_EX_ALUOut,
                        ID_EX_instruction,
                                            MEM_WB_MemData,
                                            MEM_WB_WriteData,
                                            MEM_WB_ALUOut;
    
    // lab6. for memory latency
    // while memory accessing doesn't finish, stop all state registers..
    assign EX_MEM_MemRW = ( EX_MEM_MemRead || EX_MEM_MemWrite ) && ( !d_doneM ) ; 
    
    
    
    assign IF_ID_RegisterRs = IF_ID_instruction[11:10];
    assign IF_ID_RegisterRt = IF_ID_instruction[ 9: 8];
    assign IF_ID_RegisterRd = IF_ID_instruction[ 7: 6];
    assign IF_ID_Imm        = IF_ID_instruction[ 7: 0];
    assign IF_ID_PCJump     = ID_EX_ControlSig[13] ? ID_EX_DataA :
                              ( ControlSig[12] ? { PCSource[15:12], IF_ID_instruction[11:0]} : IF_ID_PCSource + 1 );
    assign ID_EX_PCBranch   = ID_EX_PCSource + ID_EX_DataImm;  
       
    // always not-taken predictor
    assign PCNext  = WrongPredict ? ID_EX_PCBranch : IF_ID_PCJump;       
    assign PCWrite = !( HarzardDetection || 
                        IF_ID_ControlSig[13] ||                           // for jump to reg
                        (ID_EX_ControlSig[1] && !ID_EX_ControlSig[13])  || // for jump and link 
                        EX_MEM_MemRW );
    
    assign Stall   = HarzardDetection ||      // detect load data harzard
 //                    EX_MEM_WrongPredict || 
                     ID_EX_ControlSig[13] || EX_MEM_JumptoReg ||  // jump to register
                     ID_EX_ControlSig[12] ||  // jump                     
                     ID_EX_ControlSig[1] || EX_MEM_ControlSig[1]  ; // link for data write
                     
    assign is_halted   = ID_EX_ControlSig[15];

    BranchDecision bdc(
        .ID_EX_instruction( ID_EX_instruction ),
        .Data1( ID_EX_DataA    ),
        .Data2( ID_EX_ForwardB ),
        .Decision( WrongPredict )    
    );
            
    /*
    mux mux_PCSrc(
        .in ( { IF_ID_PCBranch, IF_ID_PCJump } ),
        .sel( Branch ),
        .out( PCNext )
    );
    */ 
   
    IF_ID ifid (
        .Clk        ( Clk     ),
        .Reset_N    ( Reset_N ),
        .IF_ID_Write( !HarzardDetection ),
        .IF_ID_Flush( WrongPredict ), // NOP = no flush
        .EX_MEM_MemRW( EX_MEM_MemRW ),
        
        .PCSource          (         PCSource),
        .instruction       (      instruction),
        .IF_ID_PCSource    (   IF_ID_PCSource),
        .IF_ID_instruction (IF_ID_instruction)
    );
    
    RegisterFile rf(
        .clk    ( !Clk              ),
        .reset_n( Reset_N           ),
        .Write  ( MEM_WB_RegWrite ),
    
        .Addr1  ( IF_ID_RegisterRs  ),
        .Addr2  ( IF_ID_RegisterRt  ),
        .Addr3  ( MEM_WB_RegisterRd ),
        
        .Data1  ( IF_ID_DataRs      ),
        .Data2  ( IF_ID_DataRt      ),
        .Data3  ( MEM_WB_WriteData  )
    );



    SignExtend sex (
        .in ( IF_ID_Imm ),    
        .out( IF_ID_DataImm )
    );
    
    mux #( 
        .WIDTH( 16 )
    ) mux_Stall (
        .in ( { {16{ 1'b0 }}, ControlSig }),
        .sel( Stall ),
        .out( IF_ID_ControlSig )
    );
    
    ID_EX idex (
        
        .Clk     ( Clk      ),
        .Reset_N ( Reset_N  ),
        .EX_MEM_MemRW( EX_MEM_MemRW ),
    
        // Contorl Signals 
        .IF_ID_ControlSig   ( IF_ID_ControlSig ),  .ID_EX_ControlSig   ( ID_EX_ControlSig ),
        
        // Branch check
        .IF_ID_instruction  ( IF_ID_instruction),  .ID_EX_instruction  ( ID_EX_instruction ),
        .IF_ID_PCBranch     ( IF_ID_PCBranch   ),  .ID_EX_PCBranch     ( ID_EX_PCBranch ),
        .IF_ID_PCSource     ( IF_ID_PCSource   ),  .ID_EX_PCSource     ( ID_EX_PCSource ),  
        
        // Datas
        .IF_ID_DataRs       ( IF_ID_DataRs  ),     .ID_EX_DataRs       ( ID_EX_DataRs ),
        .IF_ID_DataRt       ( IF_ID_DataRt  ),     .ID_EX_DataRt       ( ID_EX_DataRt ),
        .IF_ID_DataImm      ( IF_ID_DataImm ),     .ID_EX_DataImm      ( ID_EX_DataImm ),
        .IF_ID_RegisterRs   ( IF_ID_RegisterRs ),  .ID_EX_RegisterRs   ( ID_EX_RegisterRs ),
        .IF_ID_RegisterRt   ( IF_ID_RegisterRt ),  .ID_EX_RegisterRt   ( ID_EX_RegisterRt ),
        .IF_ID_RegisterRd   ( IF_ID_RegisterRd ),  .ID_EX_RegisterRd   ( ID_EX_RegisterRd )
    );
     
    mux #(
        .NUM_INPUTS(3),
        .SEL_WIDTH(2)
    ) mux_ForwardA (
        .in ({ EX_MEM_ALUOut, MEM_WB_WriteData, ID_EX_DataRs }),
        .sel( ForwardA ),
        .out( ID_EX_DataA )
    );
     
    mux #(
        .NUM_INPUTS(3),
        .SEL_WIDTH(2)
    ) mux_ForwardB (
        .in ({ EX_MEM_ALUOut, MEM_WB_WriteData, ID_EX_DataRt}),
        .sel( ForwardB ),
        .out( ID_EX_ForwardB )
    );

    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            num_inst    <= 0;
            output_port <= `WORD_SIZE'bz;
        end
        else begin
            if( ( ID_EX_ControlSig == 0 ) || EX_MEM_MemRW )// NOP
                num_inst <= num_inst;        
            else
                num_inst <= num_inst + 1;
            if( ID_EX_ControlSig[11] ) // isWWD
                output_port <= ID_EX_ALUOut;
            else
                output_port <= output_port;
        end
    end
        
    mux #(
        .WIDTH(2)
    ) mux_RegDst (
        .in ({ ID_EX_RegisterRd, ID_EX_RegisterRt }),
        .sel( ID_EX_ControlSig[10] ), // RegDst
        .out( ID_EX_dest ) 
    );
    
    mux mux_ALUSrc(
        .in ({ ID_EX_DataImm, ID_EX_ForwardB }),
        .sel( ID_EX_ControlSig[9] ), // ALUSrc
        .out( ID_EX_DataB )
    );
    
    ALU alu(
        .A   ( ID_EX_DataA ),
        .B   ( ID_EX_DataB ),
        .Cin ( 0 ),
        .OP  ( ID_EX_ControlSig[8:5] ), // ALUOp
        .C   ( ID_EX_ALUOut ),
        .Cout(),
        .Zero()
    );
    
    
    assign EX_MEM_MemRead  = EX_MEM_ControlSig[4];
    assign EX_MEM_MemWrite = EX_MEM_ControlSig[3];
    
    EX_MEM exmem(
        .Clk(Clk),
        .Reset_N(Reset_N),
        .EX_MEM_MemRW( EX_MEM_MemRW ),
        
        .ID_EX_PCSource     ( ID_EX_PCSource   ),  .EX_MEM_PCSource     ( EX_MEM_PCSource ),  
        
        .ID_EX_WrongPredict( WrongPredict )      , .EX_MEM_WrongPredict ( EX_MEM_WrongPredict),
        .ID_EX_JumptoReg ( ID_EX_ControlSig[13] ), .EX_MEM_JumptoReg    ( EX_MEM_JumptoReg ),
                
        // {MemRead, MemWrite, MemtoReg, RegLink, RegWrite }
        .ID_EX_ControlSig( ID_EX_ControlSig[4:0] ), .EX_MEM_ControlSig( EX_MEM_ControlSig ),
        .ID_EX_ALUOut    ( ID_EX_ControlSig[1] ? ID_EX_PCSource : ID_EX_ALUOut          ), .EX_MEM_ALUOut    ( EX_MEM_ALUOut     ),
        .ID_EX_WriteData ( ID_EX_ForwardB        ), .EX_MEM_WriteData ( EX_MEM_WriteData  ),
        .ID_EX_RegisterRd( ID_EX_ControlSig[1] ? 2'b10 : ID_EX_dest  ), .EX_MEM_RegisterRd( EX_MEM_RegisterRd ) 
    );
    
    
    MEM_WB memwb(
        .Clk(Clk),
        .Reset_N(Reset_N),
        .EX_MEM_MemRW( EX_MEM_MemRW ),
              
        // { MemtoReg, RegLink, RegWrite }
        .EX_MEM_ControlSig( EX_MEM_ControlSig[2:0]), .MEM_WB_ControlSig( MEM_WB_ControlSig ),
        
        .EX_MEM_PCSource     ( EX_MEM_PCSource   ),  .MEM_WB_PCSource  ( MEM_WB_PCSource ),  
        
        .EX_MEM_MemData   ( EX_MEM_MemData        ), .MEM_WB_MemData   ( MEM_WB_MemData ),
        .EX_MEM_ALUOut    ( EX_MEM_ALUOut         ), .MEM_WB_ALUOut    ( MEM_WB_ALUOut ),
        .EX_MEM_RegisterRd( EX_MEM_RegisterRd     ), .MEM_WB_RegisterRd( MEM_WB_RegisterRd )
    );
    
    mux mux_MemtoReg(
            .in ({MEM_WB_MemData, MEM_WB_ALUOut}),
            .sel( MEM_WB_ControlSig[2] ),
            .out( MEM_WB_WriteData )
    );
    
    
    assign EX_MEM_RegWrite = EX_MEM_ControlSig[0];
    assign MEM_WB_RegWrite = MEM_WB_ControlSig[0];
    ForwardingUnit fu (
        .EX_MEM_RegWrite  ( EX_MEM_RegWrite ),
        .MEM_WB_RegWrite  ( MEM_WB_RegWrite ),
        .ID_EX_RegisterRs ( ID_EX_RegisterRs ),
        .ID_EX_RegisterRt ( ID_EX_RegisterRt ),
        .EX_MEM_RegisterRd( EX_MEM_RegisterRd ),
        .MEM_WB_RegisterRd( MEM_WB_RegisterRd ),
        
        .ForwardA( ForwardA ),
        .ForwardB( ForwardB )
    );    
    assign ID_EX_MemRead = ID_EX_ControlSig[4];
    HarzardDetectionUnit hdu(
        .ID_EX_MemRead   (ID_EX_MemRead),
        .IF_ID_RegisterRs(IF_ID_RegisterRs),
        .IF_ID_RegisterRt(IF_ID_RegisterRt),
        .ID_EX_RegisterRt(ID_EX_RegisterRt),
        
        .HarzardDetection(HarzardDetection)
    ); 

endmodule
