`include "constants.v"
`define NUM_OF_LINE 4
`define LINE_SIZE   4

module Cache (
    
    // lab 7 DMA
    output reg cache_miss,

    input Clk,
    input Reset_N,
    
    // Datapath Interface
    input c_readM,
    input c_writeM,
    input [`WORD_SIZE-1:0] c_address,
    inout [`WORD_SIZE-1:0] c_data,
    
    output reg c_doneM,
    
    // Main memory Interface
    output reg d_readM,
    output reg d_writeM,
    output reg [`WORD_SIZE-1:0] d_address,
    inout  [`WORD_SIZE-1:0] d_data

);
    
    wire cache_hit;
    wire [12-1:0] in_tag;
    wire [2-1:0] in_index, in_offset; 
    reg [`WORD_SIZE-1:0] c_outputData, d_outputData;
    
    reg         table_valid [`NUM_OF_LINE-1:0];
    reg[12-1:0] table_tag   [`NUM_OF_LINE-1:0];       // table_tab [in_index]           == 12bit tag          
    reg[16-1:0] table_data  [`NUM_OF_LINE-1:0][`LINE_SIZE-1:0]; // table_data[in_index][in_offset] == 16bit data
    
    integer Rhit, Rmiss, Whit, Wmiss;
       
    assign cache_hit = ( table_valid[in_index] == 1 ) && ( table_tag[in_index] == in_tag );
    
    assign in_tag    = c_address[15:4];
    assign in_index  = c_address[ 3:2]; //  # of Line = Capacity / Line size = 4 = 2^2
    assign in_offset = c_address[ 1:0]; //  Line size = 4 = 2^2
    
    assign c_data    = c_readM  ? c_outputData : `WORD_SIZE'bz;  
    assign d_data    = c_writeM ? c_data       : `WORD_SIZE'bz;     
            
    always @ ( posedge Clk ) begin
        if( !Reset_N ) begin
            table_valid[0] = 0;
            table_valid[1] = 0;
            table_valid[2] = 0;
            table_valid[3] = 0;
            Rhit  = 0;
            Rmiss = 0;
            Whit  = 0;
            Wmiss = 0;
            cache_miss <= 0;
        end
        else begin
            if( c_readM ) begin // Request type : Read
                if( cache_hit ) begin // Cache hit : true  
                    // Return data 
                    c_outputData <= table_data[in_index][in_offset];
                    c_doneM <= 1;
                    Rhit = Rhit + 1;
                end
                else begin
                    cache_miss <= 1;
                    c_doneM <= 0;
                    // Locate a cache block to use
                    d_readM   <= 1;
                    d_writeM  <= 0;
                    // Read data from lower memory into the cache block
                    d_address <= { in_tag, in_index, 2'b00 };
                    @(posedge Clk)
                    table_data[in_index][0] <= d_data;
                    d_address <= d_address + 1;
                    @(posedge Clk)
                    table_data[in_index][1] <= d_data;
                    d_address <= d_address + 1;
                    @(posedge Clk)
                    table_data[in_index][2] <= d_data;
                    d_address <= d_address + 1;
                    @(posedge Clk)
                    table_data[in_index][3] <= d_data;
                    d_address <= d_address + 1;
                    @(posedge Clk)
                    // Return data
                    table_valid[in_index] <= 1;
                    table_tag  [in_index] <= in_tag;
                    d_readM <= 0;
                    c_outputData <= table_data[in_index][in_offset];
                    cache_miss <= 0;
                    c_doneM <= 1;
                    Rmiss = Rmiss + 1;
                end
            end
            else if( c_writeM ) begin // Request type : Write
                c_doneM <= 0;
                cache_miss <= 1;
                if( cache_hit ) begin // Cache hit : true
                    // Write data into cache block
                    table_data[in_index][in_offset] <= c_data;
                   
                    
                    // Write data into lower memory
                    d_readM   <= 0;
                    d_writeM  <= 1;
                    d_address <= c_address;
                    repeat( 5 ) @( posedge Clk );
                    d_writeM  <= 0;
                    c_doneM   <= 1;
                    Whit = Whit + 1;
                end
                else begin
                    // Write data into lower memory
                    d_readM   <= 0;
                    d_writeM  <= 1;
                    d_address <= c_address;
                    repeat( 5 ) @( posedge Clk );
                    d_writeM  <= 0;
                    c_doneM   <= 1;
                    Wmiss = Wmiss + 1; 
                end
                cache_miss <= 0;
            end
            else
                c_doneM <= 0;
        end
    end

endmodule