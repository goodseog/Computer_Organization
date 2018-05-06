`include "opcodes.v"
`include "constants.v"

    //                          15       14        13      12    11     10        9     8-5       4        3        2         1        0
   // assign ControlSig  = { isHalted, Branch, JumptoReg , Jump, isWWD, RegDst, ALUSrc, ALUOp, MemRead, MemWrite, MemtoReg, RegLink, RegWrite };

module ControlUnit(
    
    // Basic
    input Clk, 
    input Reset_N, 
    
    // Instruction memory interface
    output                      i_readM, 
    output reg                  i_writeM, 
    output reg [`WORD_SIZE-1:0] i_address,  // current PC 
    inout      [`WORD_SIZE-1:0] i_data, 

    // Data memory interface
    output                   d_readM, 
    output                   d_writeM, 
    output  [`WORD_SIZE-1:0] d_address, 
    inout   [`WORD_SIZE-1:0] d_data, 

    output [`WORD_SIZE-1:0] num_inst, 
    output [`WORD_SIZE-1:0] output_port, 
    
    input                   is_halted_dp,
    output reg              is_halted,
    
    
    // Datapath interface
    
    output     [`WORD_SIZE-1:0] instruction,
    output     [`WORD_SIZE-1:0] PCSource,
    
    input      [`WORD_SIZE-1:0] IF_ID_instruction,
    
    input                       EX_MEM_MemRead,
    input                       EX_MEM_MemWrite,
    input      [`WORD_SIZE-1:0] EX_MEM_ALUOut,
    input      [`WORD_SIZE-1:0] EX_MEM_WriteData,
    output     [`WORD_SIZE-1:0] EX_MEM_MemData,
    
    input                       PCWrite,
    input      [`WORD_SIZE-1:0] PCNext,
    
    // Control Signals
    output [ 15 : 0] ControlSig 
                       
    
);

    wire
        Branch,
        JumptoReg,
        Jump,
        isWWD,
        RegDst,
        ALUSrc,
        MemRead,
        MemWrite,
        MemtoReg,
        RegLink,
        RegWrite; 

    wire [3:0]
        Opcode,
        ALUOp,
        w_ALUOp;
    wire [5:0] Func;
    
    //                        15       14        13      12    11     10        9     8-5       4        3        2         1        0
    assign ControlSig  = { isHalted, Branch, JumptoReg , Jump, isWWD, RegDst, ALUSrc, ALUOp, MemRead, MemWrite, MemtoReg, RegLink, RegWrite };
    assign instruction = i_data;
    assign i_readM     = Reset_N;
    assign PCSource    = i_address;

    // Program Counter control
    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            i_writeM  <= 0;
            i_address <= 0;
            is_halted <= 0;
        end
        else begin
            if( PCWrite ) i_address   <= PCNext;
            else          i_address   <= i_address;
            if( is_halted_dp )
                is_halted <= 1;
        end
    end
    
    // Data memory IN/OUT
    assign d_readM   = EX_MEM_MemRead;
    assign d_writeM  = EX_MEM_MemWrite;
    assign d_address = EX_MEM_ALUOut;
    assign d_data    = d_writeM ? EX_MEM_WriteData : `WORD_SIZE'bz;
    
    assign EX_MEM_MemData = d_data;
    
    // Assign Control signals
    assign Opcode   = IF_ID_instruction[15:12];
    assign Func     = IF_ID_instruction[5:0];

    
    assign isHalted  = ( Opcode == `OPCODE_RTYPE ) && ( Func == `FUNC_HLT );  
    assign Branch    = ( IF_ID_instruction != 0 ) && (( Opcode == `OPCODE_BNE ) || ( Opcode == `OPCODE_BEQ ) || ( Opcode == `OPCODE_BGZ ) || ( Opcode == `OPCODE_BLZ ));
    assign JumptoReg = ( Opcode == `OPCODE_RTYPE ) && (( Func == `FUNC_JPR ) || ( Func == `FUNC_JRL ));
    assign Jump      = ( IF_ID_instruction != 0 ) && (( Opcode == `OPCODE_JMP ) || ( Opcode == `OPCODE_JAL ));
    assign isWWD     = ( Opcode == `OPCODE_RTYPE ) && ( Func == `FUNC_WWD );
    assign RegDst    = ( Opcode == `OPCODE_RTYPE ) ;
    assign ALUSrc    = ( Opcode == `OPCODE_ADI ) || ( Opcode == `OPCODE_ORI ) || ( Opcode == `OPCODE_LHI ) ||
                       ( Opcode == `OPCODE_LWD ) || ( Opcode == `OPCODE_SWD ) ;
    assign RegLink   = ( Opcode == `OPCODE_JAL ) || ( ( Opcode == `OPCODE_RTYPE ) && ( Func == `FUNC_JRL ) );
    assign RegWrite  = ( Opcode == `OPCODE_ADI ) || ( Opcode == `OPCODE_ORI ) || ( Opcode == `OPCODE_LHI ) || ( Opcode == `OPCODE_JAL ) || ( Opcode == `OPCODE_LWD ) ||
                       ( ( Opcode == `OPCODE_RTYPE ) && ( ( Func == `FUNC_ADD ) || ( Func == `FUNC_SUB ) || ( Func == `FUNC_AND ) || ( Func == `FUNC_ORR ) ||  
                                                          ( Func == `FUNC_NOT ) || ( Func == `FUNC_TCP ) || ( Func == `FUNC_SHL ) || ( Func == `FUNC_SHR ) || 
                                                          ( Func == `FUNC_JRL ) ) );
    assign MemRead  = ( Opcode == `OPCODE_LWD );
    assign MemWrite = ( Opcode == `OPCODE_SWD );
    assign MemtoReg = ( Opcode == `OPCODE_LWD );
    ALUControl aluc (
        .Opcode( Opcode  ),
        .Func  ( Func    ),
        .ALUOp ( ALUOp   )            
    ); 
    
endmodule
