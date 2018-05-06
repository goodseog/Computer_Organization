`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal, 
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal 
*         READ signal
*         memory address (addr) to be written by the device, 
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports 
* (e.g., wire -> reg) if you want 
* Do not add more ports! 
*************************************************/

`define STATE_CMD_WAIT   0
`define STATE_BR_REQUEST 1
`define STATE_BR_DONE    2


module DMA (
    input CLK, BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input cmd,
    output reg BR, 
    output reg WRITE,
    output reg [`WORD_SIZE - 1 : 0] addr, 
    output [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt );
	
	
    /* Implement your own logic */
    /*
        1. I/O Device�� CPU�� Interrupt�� ������.
        2. CPU�� DMA Controller���� command(status, length, source, dest)�� ������.
  **    3. DMA Controller�� CPU�� Bus request(BR) ��ȣ�� ������.
        4. CPU�� bus control circuitry�� �̸� �޾� DMA Controller ���� Bus grant(BG) ��ȣ�� ������.
  **    5. DMA Controller�� bus�� �̿��Ͽ� data�� ó���ϴ� �� �� CPU�� �ش� bus�� ������� �ʴ� �۾��� �ؾ��Ѵ�.
  **    6. DMA controller�� �۾� �Ϸ�� BR�� disable�ϰ� interrupt�� �߻���Ų��.
        7. interrupt�� �߻��ϸ� CPU�� BG�� disable�ϰ� bus�� �� ������ ������.
    */
    
    reg[`WORD_SIZE-1:0] target_memory_address;
    reg[1:0] DMA_curr_state, DMA_next_state;
    
    assign data = edata;
    
    initial begin
        target_memory_address = `WORD_SIZE'h01F4;
        DMA_curr_state = `STATE_CMD_WAIT;
        WRITE = 0;
        addr = 3;
        BR = 0;
    end
    
    always @ ( posedge CLK )
        DMA_curr_state <= DMA_next_state;
    
    always @ ( * ) begin
        case( DMA_curr_state )
        `STATE_CMD_WAIT: begin
            if( cmd == 1 ) DMA_next_state = `STATE_BR_REQUEST;
            else           DMA_next_state = `STATE_CMD_WAIT;
        end
        `STATE_BR_REQUEST: begin
            if( offset == 2 ) DMA_next_state = `STATE_CMD_WAIT;
            else              DMA_next_state = `STATE_BR_REQUEST;
        end
        `STATE_BR_DONE: DMA_next_state = `STATE_CMD_WAIT;
        endcase
    end
    
    always @ ( * ) begin
        case( DMA_curr_state )
        `STATE_CMD_WAIT: begin
            BR = 0;
            WRITE = 0;
            interrupt = 0;
        end
        `STATE_BR_REQUEST: begin
            BR = 1;
            if( BG == 1 ) begin // transfer data to memory
                WRITE = 1;
                if( offset == 2 )
                    interrupt = 1;
            end
        end
        `STATE_BR_DONE: begin
            BR = 0;
        end
        endcase
    end
    
    
    always@ ( posedge CLK ) begin
        if( DMA_curr_state != `STATE_BR_REQUEST )
            offset <= 3;
        else if( DMA_curr_state == `STATE_BR_REQUEST ) begin
            if( BG == 1 ) begin
                offset <= offset + 1;
                addr   <= addr   + 4;
 //               data <= edata;     
            end
            else if( BG == 0 && offset == 3 ) begin
                offset <= 0;
                addr   <= target_memory_address;
            end
        end
    end   

endmodule


