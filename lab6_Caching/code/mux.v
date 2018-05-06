module mux #(
  parameter 
    WIDTH       = 16,
    NUM_INPUTS  =  2, 
    SEL_WIDTH   =  1  
)
(
    input  [ NUM_INPUTS * WIDTH - 1 : 0 ] in,
    input  [          SEL_WIDTH - 1 : 0 ] sel,
    output [              WIDTH - 1 : 0 ] out
);
    assign out = in >> ( sel * WIDTH );
endmodule
