`timescale 1ns/1ns
`include "opcodes.v"
`include "constants.v"

module cpu(
    input Clk, 
    input Reset_N, 

    // Instruction memory interface
    output i_readM, 
    output i_writeM, 
    output [`WORD_SIZE-1:0] i_address, 
    inout [`WORD_SIZE-1:0] i_data, 

    // Data memory interface
    output d_readM, 
    output d_writeM, 
    output [`WORD_SIZE-1:0] d_address, 
    inout [`WORD_SIZE-1:0] d_data, 

    output [`WORD_SIZE-1:0] num_inst, 
    output [`WORD_SIZE-1:0] output_port, 
    output is_halted
);

	// TODO : Implement your multi-cycle CPU!
    wire
        is_halted_dp,
        PCWrite;
    
    
    wire [15:0]
        ControlSig;

    wire [`WORD_SIZE-1:0]
        instruction,
        PCSource,
        PCNext,
        IF_ID_instruction,
        EX_MEM_MemRead,
        EX_MEM_MemWrite,
        EX_MEM_ALUOut,
        EX_MEM_WriteData,
        EX_MEM_MemData;

    ControlUnit cu (
    
        .Clk        ( Clk       ),
        .Reset_N    ( Reset_N   ),
        
               
        // Memory Interface
        .i_readM    ( i_readM   ),
        .i_writeM   ( i_writeM  ),
        .i_address  ( i_address ),
        .i_data     ( i_data    ),
        
        .d_readM    ( d_readM   ),
        .d_writeM   ( d_writeM  ),
        .d_address  ( d_address ),
        .d_data     ( d_data    ),
        
        .is_halted  ( is_halted ), 
         
         // Datapath interface
         .instruction( instruction ),
         .PCSource( PCSource ),
                  
         .IF_ID_instruction( IF_ID_instruction ),
         
         
         .EX_MEM_MemRead  ( EX_MEM_Read      ),
         .EX_MEM_MemWrite ( EX_MEM_MemWrite  ),
         .EX_MEM_ALUOut   ( EX_MEM_ALUOut    ),
         .EX_MEM_WriteData( EX_MEM_WriteData ),
         .EX_MEM_MemData  ( EX_MEM_MemData   ),
         
         .PCWrite ( PCWrite ),
         .PCNext  ( PCNext  ),
         
         // Control Signals
         .ControlSig( ControlSig ),
         
         .is_halted_dp( is_halted_dp )                  
        
    );
    
    Datapath  dp (    
        .Clk        ( Clk       ),
        .Reset_N    ( Reset_N   ),
        
        .num_inst   ( num_inst    ),
        .output_port( output_port ),
        
        .instruction( instruction ),
        .PCSource   ( PCSource ),
            
        .ControlSig ( ControlSig ),       
        // Control Unit Interface
        .IF_ID_instruction( IF_ID_instruction ),        
        .PCWrite    ( PCWrite   ),
        .PCNext     ( PCNext    ),
                       
        .EX_MEM_MemRead  ( EX_MEM_Read      ),
        .EX_MEM_MemWrite ( EX_MEM_MemWrite  ),
        .EX_MEM_ALUOut   ( EX_MEM_ALUOut    ),
        .EX_MEM_WriteData( EX_MEM_WriteData ),
        .EX_MEM_MemData  ( EX_MEM_MemData   ),    
        
        .is_halted( is_halted_dp )
    );

endmodule
