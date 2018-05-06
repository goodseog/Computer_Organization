`define WORD_SIZE 16

module Register (
    input[`WORD_SIZE-1:0] in,
    input write,
    input clock,
    output reg [`WORD_SIZE-1:0] out
);  

    always @( posedge clock ) begin
        if( write ) out <= in;
        else        out <= out;
    end
    
endmodule