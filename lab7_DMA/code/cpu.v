`timescale 1ns/1ns
`include "opcodes.v"
`include "constants.v"

`define WAIT_DMA_BEGIN  0
`define WAIT_BR_BEGIN   1
`define WAIT_BR_END     2
`define WAIT_DMA_END    3

module cpu(
    // lab7 DMA interface
    input DMA_begin,
    input DMA_end,
    input BR,
    output reg BG,
    output reg cmd,
    
    input cache_miss,


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
        PCWrite,
        EX_MEM_MemRead,
        EX_MEM_MemWrite;
    
    
    wire [15:0]
        ControlSig;

    wire [`WORD_SIZE-1:0]
        instruction,
        PCSource,
        PCNext,
        IF_ID_instruction,
        EX_MEM_ALUOut,
        EX_MEM_WriteData,
        EX_MEM_MemData,
        c_address, c_data;

    /*
        1. I/O Device가 CPU에 Interrupt를 보낸다.
    **  2. CPU가 DMA Controller에게 command 를 보낸다.
        3. DMA Controller가 CPU에 Bus request(BR) 신호를 보낸다.
    **  4. CPU의 bus control circuitry가 이를 받아 DMA Controller 에게 Bus grant(BG) 신호를 보낸다.
    **  5. DMA Controller가 bus를 이용하여 data를 처리하는 동 안 CPU는 해당 bus를 사용하지 않는 작업을 해야한다.
        6. DMA controller는 작업 완료시 BR을 disable하고 interrupt를 발생시킨다.
    **  7. interrupt가 발생하면 CPU는 BG를 disable하고 bus를 정 상으로 돌린다.
    */
    reg[1:0] DMA_curr_state, DMA_next_state;
    
    initial begin
        DMA_curr_state = `WAIT_DMA_BEGIN;
        cmd = 0;
    end
    
    always @ ( posedge Clk ) begin
        if( !Reset_N ) DMA_curr_state <= `WAIT_DMA_BEGIN;
        else           DMA_curr_state <= DMA_next_state;
    end
    
    // Decide next state
    always @ ( * ) begin
        case( DMA_curr_state )
        `WAIT_DMA_BEGIN: begin
            if( DMA_begin == 1 ) DMA_next_state = `WAIT_BR_BEGIN;
            else                 DMA_next_state = `WAIT_DMA_BEGIN;
        end
        `WAIT_BR_BEGIN: begin
            if( BR == 1 ) DMA_next_state = `WAIT_BR_END;
            else          DMA_next_state = `WAIT_BR_BEGIN;
        end
        `WAIT_BR_END: begin
            if( DMA_end == 1 ) DMA_next_state = `WAIT_DMA_BEGIN;
            else               DMA_next_state = `WAIT_BR_END;
        end
        endcase
    end

    // Decide process
    always @ ( * ) begin
        case( DMA_curr_state )
        `WAIT_DMA_BEGIN : begin 
            BG = 0;
        end 
        `WAIT_BR_BEGIN : begin
            cmd = 1; 
        end
        `WAIT_BR_END: begin
            cmd = 0;
            if( cache_miss == 0 )
                BG = 1;
            else if( cache_miss == 1 )
                BG = 0;
        end
        `WAIT_DMA_END: begin
            // 9. The CPU clears the BG signal and enables using memory buses.
            BG  = 0;
            
        end
        endcase
    end    

    Cache DMC (
        .cache_miss( cache_miss ),
    
        .Clk ( !Clk ),
        .Reset_N( Reset_N ),
        
        // Control Unit - Cache Interface
        .c_readM    ( c_readM   ),
        .c_writeM   ( c_writeM  ),
        .c_address  ( c_address ),
        .c_data     ( c_data    ),
        .c_doneM    ( c_doneM   ),
        
        // Cache - Main memory Interface
        .d_readM    ( d_readM   ),
        .d_writeM   ( d_writeM  ),
        .d_address  ( d_address ),
        .d_data     ( d_data    )
    );

    ControlUnit CU (
    
        .Clk        ( Clk       ),
        .Reset_N    ( Reset_N   ),
        
               
        // Memory Interface
        .i_readM    ( i_readM   ),
        .i_writeM   ( i_writeM  ),
        .i_address  ( i_address ),
        .i_data     ( i_data    ),
        
        .c_doneM    ( c_doneM   ),
        .c_readM    ( c_readM   ),
        .c_writeM   ( c_writeM  ),
        .c_address  ( c_address ),
        .c_data     ( c_data    ),
        
        .d_doneM    ( d_doneM   ),
        
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
    
    Datapath  DP (    
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
        
        .is_halted( is_halted_dp ),
        
        .d_doneM  ( d_doneM )
    );

endmodule
